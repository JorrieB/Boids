//
//  Boid.swift
//  Boids
//
//  Created by Jottie Brerrin on 2/14/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class Boid: CCSprite {
  
  let MAX_VELOCITY : CGFloat = 1.5
  
  var velocity = CGPoint()
  var delegate : BoidDelegate!
  
  
  //MARK: Rule Variables
  //Rule 1
  let VISIBLE_DIS : CGFloat = 60
  let COHESION : CGFloat = 900
  //Rule 2
  let COLLIDE_DIS : CGFloat = 20
  let SEPARATION : CGFloat = 150
  //Rule 3
  let ALIGNMENT : CGFloat = 150

  override func update(delta: CCTime) {
    
    let v1 = rule1()
    let v2 = rule2()
    let v3 = rule3()
    
    velocity = sumOf([velocity,v1,v2,v3])
    
    speedCheck()
    position = sumOf([velocity,position]) //update position by velocity
    position = modulo(position)
    
    rotation = atan2(Float(velocity.x), Float(velocity.y)) * 180 / Float(M_PI)
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
  
  // Cohesion
  // Boids steer toward other nearby boids
  func rule1() -> CGPoint{
    let visibleBoids = delegate.getBoidPositionsWithin(VISIBLE_DIS, ofBoid: self)
    let cohesionVector = vectorToCenterPointOf(visibleBoids)
    return CGPoint(x: cohesionVector.x/COHESION, y:cohesionVector.y/COHESION)
  }
  
  //Separation
  //Boids avoid colliding with nearby boids
  func rule2() -> CGPoint {
    let boidsTooClose = delegate.getBoidPositionsWithin(COLLIDE_DIS, ofBoid: self)
    var separationVector = vectorToCenterPointOf(boidsTooClose)
    separationVector = CGPoint(x:-separationVector.x,y:-separationVector.y)
    return CGPoint(x: separationVector.x/SEPARATION, y: separationVector.y/SEPARATION)
  }
  
  //Alignment
  //Boids match the movement of nearby boids
  func rule3() -> CGPoint {
    let boidVelocities = delegate.getBoidVelocitiesWithin(VISIBLE_DIS, ofBoid:self)
    let alignmentVector = avgOf(boidVelocities)
    return CGPoint(x: alignmentVector.x / ALIGNMENT, y: alignmentVector.y / ALIGNMENT)
  }
  
}

protocol BoidDelegate {
  func getBoidPositionsWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
  func getBoidVelocitiesWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
}