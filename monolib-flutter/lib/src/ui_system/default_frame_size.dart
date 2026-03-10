enum DefaultFrameSize {
  smaller(width: 640.0),
  bigger(width: 1280.0);

  final double width;

  const DefaultFrameSize({required this.width});
}
