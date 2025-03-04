require 'test_helper'

class AllocationServiceTest < ActiveSupport::TestCase
  def setup
    @allocation_amount = 100
    @investor_amounts = [
      { name: 'Investor A', requested_amount: 150, average_amount: 100 },
      { name: 'Investor B', requested_amount: 50, average_amount: 25 }
    ]
    @service = AllocationService.new(allocation_amount: @allocation_amount, investor_amounts: @investor_amounts)
  end

  test "should allocate funds correctly" do
    @service.fund!
    assert_equal 100, @service.allocated
    assert_equal 0, @service.remaining
    assert_equal :fully_funded, @service.funding_status
  end

  test "should reset allocation" do
    @service.fund!
    @service.reset!
    assert_equal 0, @service.allocated
    assert_equal :unfunded, @service.funding_status
  end

  test "should return correct funding status" do
    assert_equal :unfunded, @service.funding_status
    @service.fund!
    assert_equal :fully_funded, @service.funding_status
  end

  test "should map investor amounts correctly" do
    investors = @service.send(:map_investor_amounts, @investor_amounts)
    assert_equal 2, investors.size
    assert_equal 'Investor A', investors.first.name
    assert_equal 150, investors.first.requested_amount
    assert_equal 100, investors.first.average_amount
  end
end

class InvestorTest < ActiveSupport::TestCase
  def setup
    @investor_data = { name: 'Investor A', requested_amount: 150, average_amount: 100 }
    @investor = AllocationService::Investor.new(@investor_data)
  end

  test "should initialize investor correctly" do
    assert_equal 'Investor A', @investor.name
    assert_equal 150, @investor.requested_amount
    assert_equal 100, @investor.average_amount
    assert_equal 0, @investor.invested
  end

  test "should fund investor correctly" do
    amount = @investor.fund(80)
    assert_equal 80, amount
    assert_equal 80, @investor.invested
  end

  test "should not overfund investor" do
    amount = @investor.fund(160)
    assert_equal 150, amount
    assert_equal 150, @investor.invested
  end

  test "should return correct investment status" do
    assert_equal :uninvested, @investor.investment_status
    @investor.fund(80)
    assert_equal :partially_invested, @investor.investment_status
    @investor.fund(70)
    assert_equal :fully_invested, @investor.investment_status
  end

  test "should reset investor correctly" do
    @investor.fund(80)
    @investor.reset!
    assert_equal 0, @investor.invested
    assert_equal :uninvested, @investor.investment_status
  end
end
