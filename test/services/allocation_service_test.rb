require 'test_helper'

class AllocationServiceTest < ActiveSupport::TestCase
  def setup
    @allocation_data = {
      allocation_amount: 100,
      investor_amounts: [
        { name: 'Investor A', requested_amount: 150, average_amount: 100 },
        { name: 'Investor B', requested_amount: 50, average_amount: 25 }
      ]
    }
    @allocation = AllocationService.new(@allocation_data)
  end

  test "initialization" do
    assert_equal 100.0, @allocation.allocation
    assert_equal 2, @allocation.investors.size
  end

  test "fund!" do
    @allocation.fund!
    assert_equal 100.0, @allocation.allocated
    assert_equal :fully_funded, @allocation.funding_status

    expected_investments = { 'Investor A' => 80.0, 'Investor B' => 20.0 }
    assert_equal expected_investments, @allocation.to_h
  end

  test "funding status" do
    assert_equal :unfunded, @allocation.funding_status
    @allocation.fund!
    assert_equal :fully_funded, @allocation.funding_status
  end
end

class AllocationServiceInvestorTest < ActiveSupport::TestCase
  def setup
    @investor_data = { name: 'Investor A', requested_amount: 150, average_amount: 100 }
    @investor = AllocationService::Investor.new(@investor_data)
  end

  test "initialization" do
    assert_equal 'Investor A', @investor.name
    assert_equal 150.0, @investor.requested_amount
    assert_equal 100.0, @investor.average_amount
    assert_equal 0, @investor.invested
  end

  test "fund" do
    amount = @investor.fund(80)
    assert_equal 80.0, amount
    assert_equal 80.0, @investor.invested

    amount = @investor.fund(100)
    assert_equal 70.0, amount
    assert_equal 150.0, @investor.invested
  end

  test "investment status" do
    assert_equal :uninvested, @investor.investment_status
    @investor.fund(80)
    assert_equal :partially_invested, @investor.investment_status
    @investor.fund(70)
    assert_equal :fully_invested, @investor.investment_status
  end

  test "available?" do
    assert @investor.available?
    @investor.fund(150)
    refute @investor.available?
  end
end
