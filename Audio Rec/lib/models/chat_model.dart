class chatModel {
  String name;
  String message;
  String time;
  String url;

  chatModel({this.name, this.message, this.time, this.url});
}

List<chatModel> data = [
  chatModel(
    name: "Shruti",
    message: "Lets meet at 10 today!",
    time: "18:30",
    url:
        "https://image.shutterstock.com/image-vector/female-silhoutte-avatar-default-profile-260nw-1219366543.jpg",
  ),
  chatModel(
    name: "Jack",
    message: "You are doing great!",
    time: "16:40",
    url:
        "https://cdn1.vectorstock.com/i/thumb-large/22/05/male-profile-picture-vector-1862205.jpg",
  )
];
