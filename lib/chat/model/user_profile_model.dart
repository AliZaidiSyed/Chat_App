// Profile state model
class ProfileState {
  final String? photoUrl;
  final String? name;
  final String? email;
  final bool isLoading;
  final bool isUpLoading;
  final DateTime? createdAt;
  final String? userId;


  ProfileState(

  {

  this.photoUrl,
  this.name,
  this.createdAt,
  this.email,
  this.isLoading = false,
  this.isUpLoading = false,
    this.userId,

});

ProfileState copyWith(
{
 String? photoUrl,
 String? name,
 String? email,
 bool?isLoading,
 bool?isUpLoading,
DateTime? createdAt,
 String? userId,

}) {
  return ProfileState(
      photoUrl:photoUrl?? this.photoUrl,
      name:name?? this.name,
      createdAt:createdAt  ?? this.createdAt,
      email:email?? this.email,
      isLoading:isLoading?? this.isLoading,
      isUpLoading:isUpLoading?? this.isUpLoading,

      userId:userId ?? this.userId,
  );}
}
