//
//  Boid.swift
//  Boids
//
//  Created by Jottie Brerrin on 2/14/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class Boid: CCSprite {
  
  let MAX_VELOCITY : CGFloat = 1.5 //arbitrary speed limit
  
  var velocity = CGPoint()
  var delegate : BoidDelegate!
  
  
//MARK: Rule Variables
  //Rule 1
  
  //Rule 2
  
  //Rule 3

  override func update(delta: CCTime) {
    
    //calculate velocities from each rule
    let v1 = rule1()
    let v2 = rule2()
    let v3 = rule3()
    
    velocity = sumOf([velocity,v1,v2,v3])//find the new velocity
    
    speedCheck() //ensure the velocity is below speed limit
    position = sumOf([velocity,position]) //update position by velocity
    position = modulo(position) //modulus the position of the boid such that it wraps around the screen
    
    rotation = atan2(Float(velocity.x), Float(velocity.y)) * 180 / Float(M_PI) //match the boid's orientation with its current velocity
  }
  
  
//MARK: Boid helpers
  
  //Limits magnitude of boid velocity
  private func speedCheck(){
    let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
    velocity = speed < MAX_VELOCITY ? velocity : CGPoint(x: velocity.x / speed * MAX_VELOCITY, y: velocity.y / speed * MAX_VELOCITY)
  }
  
  //Used to wrap boids around screen
  private func modulo(point:CGPoint) -> CGPoint{
    let newX = point.x < 0 ? screenWidth + (point.x % screenWidth) : point.x % screenWidth
    let newY = point.y < 0 ? screenHeight + (point.y % screenHeight) : point.y % screenHeight
    return CGPoint(x: newX, y: newY)
  }
 
  
//MARK: CGPoint helpers
  
  //Returns the sum of an array of points
  private func sumOf(points:[CGPoint]) -> CGPoint{
    var sum = CGPoint(x: 0, y: 0)
    for point in points{
      sum = CGPoint(x: sum.x + point.x, y: sum.y + point.y)
    }
    return sum
  }
  
  //Returns average of set of CGPoints
  private func avgOf(points:[CGPoint]) -> CGPoint{
    if points.count == 0 {
      return CGPoint() // returns the zero point
    }
    let sum = sumOf(points)
    return CGPoint(x: sum.x/CGFloat(points.count), y: sum.y/CGFloat(points.count))

  }
  
  //Returns vector from self to central point of given array
  private func vectorToCenterPointOf(points:[CGPoint]) -> CGPoint {
    if points.count == 0 {
      return CGPoint() // returns the zero point
    }
    let sum = sumOf(points)
    return CGPoint(x: sum.x/CGFloat(points.count) - position.x, y: sum.y/CGFloat(points.count) - position.y)
  }
  
  
//MARK: Rules
  
  //Cohesion
  //Boids steer toward other nearby boids
  func rule1() -> CGPoint{
    return CGPoint()
  }
  
  //Separation
  //Boids avoid colliding with nearby boids
  func rule2() -> CGPoint {
    return CGPoint()
  }
  
  //Alignment
  //Boids match the movement of nearby boids
  func rule3() -> CGPoint {
    return CGPoint()
  }
  
}

protocol BoidDelegate {
  //x : the distance in pixels which the given boid can see
  //ofBoid : the boid which is searching for neighbors
  //returns : a list of the positions of the found neighbors
  func getBoidPositionsWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
  
  //x : the distance in pixels which the given boid can see
  //ofBoid : the boid which is searching for neighbors
  //returns : a list of the velocities of the found neighbors
  func getBoidVelocitiesWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
}