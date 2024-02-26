class Api::V1::AnimalsController < ApplicationController
  def index
    render json: Animal.all
  end

  def create
    Animal.create!(name: "Animal",species: "Terrestre", age: "20")
    render status: :created
  end
end
