describe "acts_as_immutable" do
  let!(:account) { Account.create number: 123, customer: 'Borges', active: true }

  it "does not allow changes after lock down" do
    expect(account).to be_mutable
    account.active = false
    expect(account).to_not be_mutable
  end

  it "supports transitive lock downs" do
    account.active = false
    payment = account.payments.create amount: 15000
    expect(payment).to_not be_persisted
  end
end
