RSpec.describe Article do
  describe '#valid?' do
    context 'when attributes are valid' do
      let(:user) { User.create(name: 'name') }

      it do
        article = Article.new(user: user, title: 'title', content: 'content')
        expect(article.valid?).to be false
      end
    end
  end
end
