#!/usr/bin/env ruby

# Courier Service Command Line Application
# Reads input from stdin and outputs results to stdout

class Offer
  attr_reader :code, :discount_percent, :distance_range, :weight_range

  def initialize(code, discount_percent, distance_range, weight_range)
    @code = code
    @discount_percent = discount_percent
    @distance_range = distance_range
    @weight_range = weight_range
  end

  def applicable?(weight, distance)
    weight_range.cover?(weight) && distance_range.cover?(distance)
  end
end

class Package
  attr_reader :id, :weight, :distance, :offer_code
  attr_accessor :discount, :total_cost, :delivery_time

  def initialize(id, weight, distance, offer_code)
    @id = id
    @weight = weight
    @distance = distance
    @offer_code = offer_code
    @discount = 0
    @total_cost = 0
    @delivery_time = 0
  end

  def calculate_base_cost(base_delivery_cost)
    base_delivery_cost + (@weight * 10) + (@distance * 5)
  end
end

class Vehicle
  attr_reader :id, :max_weight, :speed
  attr_accessor :available_at

  def initialize(id, max_weight, speed)
    @id = id
    @max_weight = max_weight
    @speed = speed
    @available_at = 0
  end

  def travel_time(distance)
    distance.to_f / speed
  end
end

class CourierService
  OFFERS = [
    Offer.new('OFR001', 10, 0...200, 70..200),
    Offer.new('OFR002', 7, 50..150, 100..250),
    Offer.new('OFR003', 5, 50..250, 10..150)
  ].freeze

  def initialize(base_delivery_cost)
    @base_delivery_cost = base_delivery_cost
    @packages = []
    @vehicles = []
  end

  def add_package(id, weight, distance, offer_code)
    package = Package.new(id, weight, distance, offer_code)
    @packages << package
  end

  def add_vehicles(num_vehicles, max_speed, max_weight)
    num_vehicles.times do |i|
      @vehicles << Vehicle.new(i + 1, max_weight, max_speed)
    end
  end

  def calculate_delivery_costs
    @packages.each do |package|
      delivery_cost = package.calculate_base_cost(@base_delivery_cost)
      
      offer = OFFERS.find { |o| o.code == package.offer_code }
      
      if offer && offer.applicable?(package.weight, package.distance)
        package.discount = (delivery_cost * offer.discount_percent / 100.0).round(2)
      else
        package.discount = 0
      end
      
      package.total_cost = delivery_cost - package.discount
    end
  end

  def calculate_delivery_times
    return if @vehicles.empty?

    calculate_delivery_costs

    remaining_packages = @packages.dup
    current_time = 0

    while !remaining_packages.empty?
      available_vehicle = @vehicles.min_by { |v| v.available_at }
      current_time = available_vehicle.available_at

      shipment = find_optimal_shipment(remaining_packages, available_vehicle.max_weight)
      
      break if shipment.empty?

      max_distance = shipment.map(&:distance).max
      
      shipment.each do |package|
        package.delivery_time = (current_time + available_vehicle.travel_time(package.distance)).round(2)
        remaining_packages.delete(package)
      end

      available_vehicle.available_at = current_time + (2 * available_vehicle.travel_time(max_distance))
    end
  end

  def find_optimal_shipment(packages, max_weight)
    return [] if packages.empty?

    best_shipment = []
    best_num_packages = 0
    best_weight = 0
    best_max_distance = Float::INFINITY

    (1..packages.length).each do |size|
      packages.combination(size).each do |combo|
        total_weight = combo.sum(&:weight)
        next if total_weight > max_weight

        num_packages = combo.length
        max_distance = combo.map(&:distance).max

        is_better = false
        
        if num_packages > best_num_packages
          is_better = true
        elsif num_packages == best_num_packages
          if total_weight > best_weight
            is_better = true
          elsif total_weight == best_weight
            if max_distance < best_max_distance
              is_better = true
            end
          end
        end

        if is_better
          best_num_packages = num_packages
          best_weight = total_weight
          best_max_distance = max_distance
          best_shipment = combo
        end
      end
    end

    best_shipment
  end

  def output_cost_results
    @packages.each do |package|
      puts "#{package.id} #{package.discount.round(0)} #{package.total_cost.round(0)}"
    end
  end

  def output_time_results
    @packages.each do |package|
      puts "#{package.id} #{package.discount.round(0)} #{package.total_cost.round(0)} #{package.delivery_time.round(2)}"
    end
  end
end

# Main program - reads from stdin
def main
  # Read first line: base_delivery_cost and no_of_packages
  first_line = gets.chomp.split
  base_delivery_cost = first_line[0].to_i
  no_of_packages = first_line[1].to_i

  service = CourierService.new(base_delivery_cost)

  # Read package details
  no_of_packages.times do
    package_line = gets.chomp.split
    pkg_id = package_line[0]
    pkg_weight = package_line[1].to_i
    pkg_distance = package_line[2].to_i
    offer_code = package_line[3]
    
    service.add_package(pkg_id, pkg_weight, pkg_distance, offer_code)
  end

  # Check if there's vehicle information (Problem 2)
  vehicle_line = gets
  
  if vehicle_line && !vehicle_line.strip.empty?
    # Problem 2: Calculate delivery times
    vehicle_data = vehicle_line.chomp.split
    no_of_vehicles = vehicle_data[0].to_i
    max_speed = vehicle_data[1].to_i
    max_weight = vehicle_data[2].to_i
    
    service.add_vehicles(no_of_vehicles, max_speed, max_weight)
    service.calculate_delivery_times
    service.output_time_results
  else
    # Problem 1: Calculate costs only
    service.calculate_delivery_costs
    service.output_cost_results
  end
end

# Run the program
main if __FILE__ == $PROGRAM_NAME
