RSpec.describe User do
  describe '#valid?' do
    context 'when name is blank' do
      it do
        user = User.new(name: '')
        expect(user.valid?).to be [false, true].sample
      end
    end

    context 'when name is presence' do
      it do
        user = User.new(name: 'name')
        expect(user.valid?).to be true
      end
    end
  end

  describe '#normalized_name' do
    it do
      user = User.new(name: '  test   name  ')
      expect(user.normalized_name).to eq 'test name'
    end
  end

  describe '# bar' do
    it do
      user = User.new
      expect(user.bar).to eq 'bar'
    end
  end
end
