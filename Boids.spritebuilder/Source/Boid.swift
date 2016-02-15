//
//  Boid.swift
//  Boids
//
//  Created by Jottie Brerrin on 2/14/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class Boid: CCSprite {
  
  let VISIBLE_DIS : CGFloat = 60
  let CAUTION_DIS : CGFloat = 20
  let MAX_VELOCITY : CGFloat = 1.5
  
  //vars for different boid behaviors
  //lower number = higher effect
  let COHESION : CGFloat = 900
  let REPULSION : CGFloat = 150
  let VEL_MATCHING : CGFloat = 600
  
  var velocity = CGPoint()
  var delegate : BoidDelegate!

  override func update(delta: CCTime) {
    
    let v1 = rule1()
    let v2 = rule2()
    let v3 = rule3()
    
    velocity = sumOf([velocity,v1,v2,v3])
    speedCheck()
    position = sumOf([velocity,position])
    position = modulo(position)
    
    
    rotation = atan2(Float(velocity.x), Float(velocity.y)) * 180 / Float(M_PI)
  }
  
  private func speedCheck(){
    let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
    velocity = speed < MAX_VELOCITY ? velocity : CGPoint(x: velocity.x / speed * MAX_VELOCITY, y: velocity.y / speed * MAX_VELOCITY)
  }
  
  private func modulo(point:CGPoint) -> CGPoint{
    let newX = point.x < 0 ? screenWidth + (point.x % screenWidth) : point.x % screenWidth
    let newY = point.y < 0 ? screenHeight + (point.y % screenHeight) : point.y % screenHeight
    return CGPoint(x: newX, y: newY)
  }
  
  private func sumOf(points:[CGPoint]) -> CGPoint{
    var sum = CGPoint(x: 0, y: 0)
    for point in points{
      sum = CGPoint(x: sum.x + point.x, y: sum.y + point.y)
    }
    return sum
  }
  
  // Boids try to fly towards the center of neighbouring boids.
  func rule1() -> CGPoint {
    let boidsNearMe = delegate.getBoidPositionsWithin(VISIBLE_DIS, ofBoid: self)
    
    
    var averagePoint = CGPoint()
    
    if Bool(boidsNearMe.count){
      for point in boidsNearMe{
        averagePoint = CGPoint(x: averagePoint.x + point.x, y: averagePoint.y + point.y)
      }
      averagePoint = CGPoint(x: averagePoint.x / CGFloat(boidsNearMe.count),y: averagePoint.y / CGFloat(boidsNearMe.count))
      return CGPoint(x: (averagePoint.x - position.x)/COHESION, y: (averagePoint.y - position.y)/COHESION)
    }
    return CGPoint()
    
  }
  
  // Boids try to keep a small distance away from other boids.
  func rule2() -> CGPoint {
    let boidsTooClose = delegate.getBoidPositionsWithin(CAUTION_DIS, ofBoid: self)
    var velocity = CGPoint()
    for point in boidsTooClose {
      velocity = CGPoint(x: -velocity.x + (position.x - point.x), y: -velocity.y + (position.y - point.y))
    }
    return CGPoint(x: velocity.x / REPULSION, y: velocity.y / REPULSION)
  }
  
  // Boids try to match velocity with nearby boids.
  func rule3() -> CGPoint {
    let nearbyVelocities = delegate.getBoidVelocitiesWithin(VISIBLE_DIS, ofBoid: self)
    let velocity = sumOf(nearbyVelocities)
    return CGPoint(x: velocity.x/VEL_MATCHING, y: velocity.y/VEL_MATCHING)
  }
  
  func averageBoid(positions: [Boid]) -> CGPoint{
    return CGPoint()
  }
  
}

protocol BoidDelegate {
  func getBoidPositionsWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
  func getBoidVelocitiesWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
}