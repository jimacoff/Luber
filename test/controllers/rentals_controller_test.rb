require 'test_helper'

class RentalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = User.create!(
      username: "Michael", 
      email:"michael@example.com", 
      password: "password", 
      password_confirmation: "password", 
      signed_in_at: DateTime.current )
    
    @user2 = User.create!(
      username: "Justin", 
      email:"justin@example.com", 
      password: "password", 
      password_confirmation: "password",
      signed_in_at: DateTime.current )

    @car = Car.create!(
      user_id: @user1.id, 
      make: "Ford", 
      model: "Mustang", 
      year: 2000, 
      color: "red", 
      license_plate: "3asd123" )

    @rental = Rental.create!(
      user_id: @user1.id, 
      renter_id: @user2.id, 
      car_id: @car.id, 
      start_location: "Santa Barbara", 
      end_location: "Mountain View",
      start_time: "2018-10-17 20:20:37", 
      end_time: "2018-10-18 20:20:37", 
      price: 1.53, 
      status: 1, 
      terms: "My terms" )
  end

  test "should get index" do
    sign_in_as(@user1, password: "password")
    get rentals_url
    assert_response :success
  end

  test "should get new" do
    sign_in_as(@user1, password: "password")
    get new_rental_url
    assert_response :success
  end

  test "if user has no cars they can not create a rental post" do
    sign_in_as(@user2, password: "password")
    get new_rental_url
    assert_redirected_to cars_user_path(@user2.username)
    assert_not flash.empty?
  end

  test "should create rental" do
    sign_in_as(@user1, password: "password")
    assert_difference('Rental.count') do
      post rentals_url, params: { 
        rental: { 
          user_id: @rental.user_id, 
          renter_id: @rental.renter_id, 
          car_id: @rental.car_id, 
        start_location: @rental.start_location, 
        end_location: @rental.end_location, 
        start_time: @rental.start_time, 
        end_time: @rental.end_time, 
        price: @rental.price, 
        status: @rental.status, 
        terms: @rental.terms, 
        start_latitude: @rental.start_latitude, 
        start_longitude: @rental.start_longitude } }
    end

    assert_redirected_to rental_url(Rental.last)
  end

  test "should not show rental (as guest)" do
    get rental_url(@rental)
    assert_redirected_to signin_path
  end

  test "should get edit" do
    sign_in_as(@user1, password: "password")
    get edit_rental_url(@rental)
    assert_response :success
  end

  test "should update rental" do
    sign_in_as(@user1, password: "password")
    patch rental_url(@rental), params: { 
      rental: { 
        user_id: @rental.user_id, 
        renter_id: @rental.renter_id, 
        car_id: @rental.car_id, 
        start_location: @rental.start_location, 
        end_location: @rental.end_location, 
        start_time: @rental.start_time, 
        end_time: @rental.end_time, 
        price: @rental.price, 
        status: @rental.status, 
        terms: @rental.terms, 
        start_latitude: @rental.start_latitude, 
        start_longitude: @rental.start_longitude } }
    assert_redirected_to rental_url(@rental)
  end

  test "should destroy rental" do
    sign_in_as(@user1, password: "password")
    assert_difference('Rental.count', -1) do
      delete rental_url(@rental)
    end

    assert_redirected_to rentals_user_path(@user1.username)
  end

  # :show, :new, :create, :edit, :update, :destroy
  test 'should redirect when not authenticated to access rental posts' do
    get new_rental_url
    assert_not flash.empty?
    assert_redirected_to signin_url

    post rentals_url, params: { 
      rental: { 
        user_id: @rental.user_id, 
        renter_id: @rental.renter_id, 
        car_id: @rental.car_id,
        start_location: @rental.start_location, 
        end_location: @rental.end_location, 
        start_time: @rental.start_time, 
        end_time: @rental.end_time,
        price: @rental.price, 
        status: @rental.status, 
        terms: @rental.terms } }
    assert_not flash.empty?
    assert_redirected_to signin_url

    get edit_rental_url(@rental)
    assert_not flash.empty?
    assert_redirected_to signin_url

    patch rental_url(@rental), params: { 
      rental: { 
        user_id: @rental.user_id, 
        renter_id: @rental.renter_id, 
        car_id: @rental.car_id,
        start_location: @rental.start_location, 
        end_location: @rental.end_location, 
        start_time: @rental.start_time, 
        end_time: @rental.end_time,
        price: @rental.price, 
        status: @rental.status, 
        terms: @rental.terms } }
    assert_not flash.empty?
    assert_redirected_to signin_url

    delete rental_url(@rental)
    assert_not flash.empty?
    assert_redirected_to signin_url
  end

  test 'should redirect when not owner of rentalpost EDIT' do
    sign_in_as(@user2, password: "password")
    get edit_rental_url(@rental)
    assert_redirected_to overview_user_path(@user2)
    assert_not flash.empty?
  end

  test 'should redirect when not owner of rentalpost UPDATE' do
    sign_in_as(@user2, password: "password")
    patch rental_url(@rental), params: { 
      rental: { 
        user_id: @rental.user_id, 
        renter_id: @rental.renter_id, 
        car_id: @rental.car_id,
        start_location: @rental.start_location, 
        end_location: @rental.end_location, 
        start_time: @rental.start_time, 
        end_time: @rental.end_time,
        price: @rental.price, 
        status: @rental.status, 
        terms: @rental.terms } }
    assert_redirected_to overview_user_path(@user2)
    assert_not flash.empty?
  end

  test 'should redirect when not owner of rentalpost DELETE' do
    sign_in_as(@user2, password: "password")
    delete rental_url(@rental)
    assert_redirected_to overview_user_path(@user2)
    assert_not flash.empty?
  end

end
