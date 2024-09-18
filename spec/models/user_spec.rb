RSpec.describe User do
  describe '#valid?' do
    context 'when name is blank' do
      it 'is invalid' do
        user = User.new(name: '')
        expect(user.valid?).to be false
      end
    end

    context 'when name is presence' do
      it 'is valid' do
        user = User.new(name: 'name')
        expect(user.valid?).to be true
      end
    end
  end
end
