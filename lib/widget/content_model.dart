// ignore_for_file: public_member_api_docs, sort_constructors_first
class UnboardingContent {
  String image;
  String title;
  String description;
  UnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

List<UnboardingContent> contents = [
  UnboardingContent(
    image: "images/screen1.png",
    title: "Select from Our\n     Best Menu",
    description: "Pick your food from our menu\n            More then 35 times",
  ),
  UnboardingContent(
    image: "images/screen2.png",
    title: "Easy and Online Payment",
    description:
        "You can pay cash on delivery and\n         Card payment is availble",
  ),
  UnboardingContent(
    image: "images/screen3.png",
    title: "Quick Delivery at Your Doorstep",
    description: "Delivery your food at your\n                 Doorstep",
  )
];
