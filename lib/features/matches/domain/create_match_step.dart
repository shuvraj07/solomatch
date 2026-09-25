/// Steps of the create-match flow, in order. Publishing happens from
/// [review].
enum CreateMatchStep {
  title('Name your match'),
  venue('Venue'),
  location('Pin the location'),
  date('Date'),
  startTime('Kick-off time'),
  endTime('Final whistle'),
  format('Format'),
  maxPlayers('How many players?'),
  positions('Positions needed'),
  skill('Skill level'),
  price('Price'),
  description('Description'),
  rules('Rules'),
  photos('Photos'),
  review('Review & publish');

  const CreateMatchStep(this.heading);

  final String heading;

  bool get isFirst => index == 0;

  bool get isLast => this == review;

  CreateMatchStep? get next => isLast ? null : values[index + 1];

  CreateMatchStep? get previous => isFirst ? null : values[index - 1];
}
