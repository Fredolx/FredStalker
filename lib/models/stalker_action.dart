enum StalkerAction {
  handshake("handshake"),
  getList("get_ordered_list"),
  createLink("create_link"),
  getCategories("get_categories"),
  getGenres("get_genres"),
  getAllChannels("get_all_channels");

  final String value;
  const StalkerAction(this.value);
}
