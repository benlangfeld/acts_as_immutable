describe "acts_as_immutable" do
  it "test" do
    expect(Payment.create).to_not eq Payment.create
  end
end
