class MemberInfo {
  final String userName;
  final String email;
  final String headerCode;
  final String transferScreenShot;

  const MemberInfo({
    required this.userName,
    required this.email,
    required this.headerCode,
    required this.transferScreenShot,
  });
}

final memberInfo = [
  const MemberInfo(
    userName: "userName",
    email: "email",
    headerCode: "headerCode",
    transferScreenShot: "assets/images/A2Z16.png",
  ),
  const MemberInfo(
    userName: "userName",
    email: "email",
    headerCode: "headerCode2",
    transferScreenShot: "assets/images/A2Z16.png",
  ),
  const MemberInfo(
    userName: "userName",
    email: "email",
    headerCode: "headerCode2",
    transferScreenShot: "assets/images/A2Z16.png",
  ),
];
