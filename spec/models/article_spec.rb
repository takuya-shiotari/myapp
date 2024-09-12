RSpec.describe Article do
  describe '#valid?' do
    context 'when attributes are valid' do
      let(:user) { User.create(name: 'name') }

      it do
        article = Article.new(user: user, title: 'title', content: 'content')
        expect(article.valid?).to be true
      end
    end
  end

  describe '#normalized_title' do
    it 'returns normalized title' do
        article = Article.new(title: ' normalized  title  ')
        expect(article.normalized_title).to eq 'normalized title'
    end
  end
end
