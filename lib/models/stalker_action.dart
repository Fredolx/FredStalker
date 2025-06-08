enum StalkerAction {
  handshake("handshake"),
  getList("get_ordered_list"),
  createLink("create_link");

  final String value;
  const StalkerAction(this.value);
}
