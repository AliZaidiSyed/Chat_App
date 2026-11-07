
import {
  createRemoteJWKSet,
  importPKCS8,
  jwtVerify,
  SignJWT,
} from "npm:jose@5.9.6";

// FIREBASE CONFIGURATION
const PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") ?? "";
const CLIENT_EMAIL = Deno.env.get("FIREBASE_CLIENT_EMAIL") ?? "";
const PRIVATE_KEY = Deno.env.get("FIREBASE_PRIVATE_KEY") ?? "";

const FIRESTORE_URL =
  `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

const firebaseJwks = createRemoteJWKSet(
  new URL(
    "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
  )
);

// CORS
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, x-client-info, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

// VERIFY FIREBASE AUTH TOKEN
async function verifyFirebaseToken(req: Request): Promise<string> {
  const authorization = req.headers.get("Authorization");

  if (!authorization?.startsWith("Bearer ")) {
    throw new Error("Firebase token missing");
  }

  const idToken = authorization.substring(7);

  const { payload } = await jwtVerify(idToken, firebaseJwks, {
    issuer: `https://securetoken.google.com/${PROJECT_ID}`,
    audience: PROJECT_ID,
    algorithms: ["RS256"],
  });

  const now = Math.floor(Date.now() / 1000);

  if (
    typeof payload.sub !== "string" ||
    !payload.sub ||
    typeof payload.exp !== "number" ||
    payload.exp <= now ||
    typeof payload.iat !== "number" ||
    payload.iat > now + 5 ||
    typeof payload.auth_time !== "number" ||
    payload.auth_time > now + 5
  ) {
    throw new Error("Invalid Firebase token");
  }

  return payload.sub;
}

// GOOGLE OAUTH TOKEN
let cachedToken = "";
let tokenExpiry = 0;

async function getGoogleAccessToken(): Promise<string> {
  if (cachedToken && Date.now() < tokenExpiry) {
    return cachedToken;
  }

  if (!PROJECT_ID || !CLIENT_EMAIL || !PRIVATE_KEY) {
    throw new Error("Firebase secrets missing");
  }

  const privateKey = await importPKCS8(
    PRIVATE_KEY.replace(/\\n/g, "\n").replace(/\r\n/g, "\n"),
    "RS256"
  );

  const now = Math.floor(Date.now() / 1000);

  const assertion = await new SignJWT({
    scope: [
      "https://www.googleapis.com/auth/datastore",
      "https://www.googleapis.com/auth/firebase.messaging",
    ].join(" "),
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(CLIENT_EMAIL)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const response = await fetch(
    "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        grant_type:
          "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion,
      }),
    }
  );

  if (!response.ok) {
    throw new Error(`Google OAuth failed: ${response.status}`);
  }

  const result = await response.json();

  cachedToken = result.access_token;
  tokenExpiry =
    Date.now() + (Math.max(60, result.expires_in - 60) * 1000);

  return cachedToken;
}

// FIRESTORE DOCUMENT READER
type FirestoreDocument = {
  fields?: Record<string, {
    stringValue?: string;
  }>;
};

async function getFirestoreDocument(
  accessToken: string,
  path: string[]
): Promise<FirestoreDocument | null> {
  const documentPath = path
    .map((part) => encodeURIComponent(part))
    .join("/");

  const response = await fetch(
    `${FIRESTORE_URL}/${documentPath}`,
    {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    }
  );

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new Error(`Firestore read failed: ${response.status}`);
  }

  return await response.json();
}

function getString(
  document: FirestoreDocument | null,
  field: string
): string {
  const value = document?.fields?.[field]?.stringValue;
  return typeof value === "string" ? value : "";
}

// SEND FCM NOTIFICATION
async function sendFCMNotification(
  accessToken: string,
  deviceToken: string,
  notification: Record<string, unknown>
) {
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: deviceToken,
          ...notification,
        },
      }),
    }
  );

  if (!response.ok) {
    console.error(
      "FCM error:",
      response.status,
      await response.text()
    );

    throw new Error("FCM notification failed");
  }

  return await response.json();
}

// MAIN EDGE FUNCTION
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    // 1. Verify sender
    const senderUid = await verifyFirebaseToken(req);

    // 2. Read request data
    const requestData = await req.json();

    const recipientUid = requestData.recipientUid;
    const notificationId = requestData.notificationId;

    if (
      typeof recipientUid !== "string" ||
      !recipientUid ||
      typeof notificationId !== "string" ||
      !notificationId
    ) {
      return jsonResponse({
        error: "Invalid recipientUid or notificationId",
      }, 400);
    }

    // 3. Get Google access token
    const accessToken = await getGoogleAccessToken();

    // 4. Read existing notification document
    const notificationDoc = await getFirestoreDocument(
      accessToken,
      [
        "users",
        recipientUid,
        "notifications",
        notificationId,
      ]
    );

    if (!notificationDoc) {
      return jsonResponse({
        error: "Notification document not found",
      }, 404);
    }

    // 5. Read existing notification fields
    const uid = getString(notificationDoc, "uid");
    const username = getString(notificationDoc, "username");
    const description = getString(notificationDoc, "description");
    const type = getString(notificationDoc, "type") || "message";
    const chatId = getString(notificationDoc, "chatId");
    const groupId = getString(notificationDoc, "groupId");
    const groupName = getString(notificationDoc, "groupName");

    // Verify notification sender
    if (!uid || uid !== senderUid) {
      return jsonResponse({
        error: "Sender verification failed",
      }, 403);
    }

    // 6. Get recipient FCM token
    const recipientDoc = await getFirestoreDocument(
      accessToken,
      ["users", recipientUid]
    );

    const deviceToken = getString(recipientDoc, "token");

    if (!deviceToken) {
      console.log("No device token for recipient");

      return jsonResponse({
        success: true,
        skipped: "No device token",
      });
    }

    // 7. ORIGINAL NOTIFICATION TITLE AND BODY LOGIC

    let title = username;
    let body = description;

    if (type === "friend_request") {
      title = "New Friend Request";
      body = `${username} sent you a friend request`;

    } else if (type === "message") {
      title = username;
      body = description;

    } else if (type === "group_message") {
      title = groupName || "Group Message";
      body = `${username}: ${description}`;
    }

    // 8. ORIGINAL FCM PAYLOAD

    const message = {
      notification: {
        title: title,
        body: body,
      },

      data: {
        uid: uid,
        notificationId: notificationId,
        chatId: chatId,
        type: type,
        groupId: groupId,
        groupName: groupName,
      },

      android: {
        priority: "HIGH",

        notification: {
          sound: "default",
          channel_id: "chat_messages_channel",
          icon: "ic_launcher",
        },
      },

      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // 9. SEND THROUGH FCM HTTP V1

    await sendFCMNotification(
      accessToken,
      deviceToken,
      message
    );

    console.log("Notification sent successfully:", title);

    return jsonResponse({
      success: true,
      notificationId: notificationId,
    });

  } catch (error) {
    console.error(
      "Notification error:",
      error instanceof Error ? error.message : "Unknown error"
    );

    return jsonResponse({
      success: false,
      error: "Failed to send notification",
    }, 500);
  }
});
