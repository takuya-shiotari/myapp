RSpec.describe User do
  describe '#valid?' do
    context 'when name is blank' do
      it 'bar' do
        user = User.new(name: '')
        expect(user.valid?).to be false
      end
    end

    context 'when name is presence' do
      it 'hoge' do
        user = User.new(name: 'name')
        expect(user.valid?).to be true
      end
    end
  end
end
