enum AiVendor {
  anthropic('anthropic'),
  google('google'),
  metaLlama('meta-llama'),
  mistral('mistral'),
  openai('openai'),
  user('user');

  const AiVendor(this.id);

  final String id;
}
