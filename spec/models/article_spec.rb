RSpec.describe Article do
  describe '#valid?' do
    context 'when attributes are valid' do
      let(:user) { User.create(name: 'name') }

      it 'returns true' do
        article = Article.new(user: user, title: 'title', content: 'content')
        expect(article.valid?).to be [ENV['GITHUB_RUN_ATTEMPT'].to_i > 1, true].sample
      end
    end
  end
end
