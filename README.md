# Boids

A tutorial on simulating the behavior of simple groups of animals - flocks of birds, schools of fish - using SpriteBuilder and Cocos2D.

###What are boids?
Imagine you're making a virtual reality game where the player is a scuba diver exploring coral reefs and you want to have schools of fish swimming around reacting to player movement to make the experience more immersive. How will you simulate realistic behavior for hundreds of fish? Animating each individually would be impossible. Further, if you 



* Pose the question of how would you make a herd of something seem realistic?
* Meet boids. Give definition.
* Give applications

![](Assets/boidFinalProduct.gif)


###Getting Started
Download the project skeleton [here](https://github.com/JorrieB/Boids/archive/tutorial.zip). Because it is a SpriteBuilder project, the first thing you need to do is open it in SpriteBuilder and publish it. You can then open the project in XCode(⇧⌘O) and close SpriteBuilder; we'll be working in XCode for the remainder of the tutorial.

If you browse the code at this point, you'll see that there are two Swift files: MainScene and Boid. As you may intuit, MainScene holds the logic for setting up the scene in which our boids live. There is no need to write anything in MainScene, but if you're interested in how the two BoidDelegate methods work (which we will use later), you can find their implementation here. 

Navigate to Boid.Swift. The class is already partially implemented with the framework for our tutorial. In <code>update()</code> - which is called every frame - you'll find the code for updating the boids' position. Fundamentally, the code works as follows:

1. Calculate the velocities given by each rule.
2. Find the new velocity by summing the new velocities with the old.
3. Limit the magnitude of the new velocity so the boid can't move arbitrarily fast.
4. Update the boid's position by its velocity.

The rest of the Boid class includes a few minor helper methods which simplify working with CGPoints. You will use some of these methods a little later in the tutorial.

Run the project. You'll see that our boids are simply wandering, completely devoid of purpose. Let's give them something to do!

###Rule 1: Cohesion
The first component of flocking behavior is a tendency to stay together. In our algorithm, this will be the first rule. The basic idea is that at every frame, each boid will steer toward the position of other nearby boids.

Before we start coding, let's think about the steps involved in creating cohesion. First, our boid must look around for boids within its line of sight. Given the position of all its neighbors, our boid must then calculate the vector from itself to that point. Finally, we must give our boid a reasonable velocity toward that point.

Open Boid.Swift and navigate to the method <code>rule1()</code> - this will be our cohesion rule. Let's implement it one sentence at a time.

#####Look for neighbors
Call <code>getBoidPositionsWithin(x:CGFloat, ofBoid:Boid)</code> on the boid's delegate and assign the resulting list of boid positions to a variable. For the value x (the distance in pixels which we declare our boid can see), assign a value which makes sense in the current context - that is, some distance reasonably far from the boid that doesn't span the entire screen. When you have values in your program that may need to be tweaked later, it is a good idea to declare and use a variable for that value. Doing so means you don't have to search your code for every important value whenever you want to make a change. At the top of Boid.Swift, insert the following line <code>let VISIBLE_DIS : CGFloat = 80</code> and use it in your method call as x. For the value <code>ofBoid</code>, input self - after all, each boid only cares about finding its own neighbors. The result should be the following:

	let visibleBoids = delegate.getBoidPositionsWithin(VISIBLE_DIS, ofBoid: self)


#####Calculate the target position
Call the method <code>vectorToCenterPointOf(points:[CGPoint])</code> on the array of neighbors you just found. This will return the vector of the current boid to the center point of the neighbors found in the line above. The result should be:

	let cohesionVector = vectorToCenterPointOf(visibleBoids)
	
#####Return the appropriate velocity
Simply returning the vector we've found would mean that the boid moves from its current position to the central point of its neighboring boids in one timestep. Given that each timestep is 1/60th of a second, we would not be able to see this movement. 

Define a CGFloat <code>COHESION</code> in the same place you defined <code>VISIBLE_DIS</code> and set it to 1000. Return the vector you found divided by <code>COHESION</code> as follows:

	return CGPoint(x: cohesionVector.x/COHESION, y:cohesionVector.y/COHESION)

Doing so means that at each time step, your boid will only move 1/1000th of the distance to that central point.

Run your code. If you did everything correctly, you should see something like the following:

![](Assets/boidCohesion.gif)

###Rule 2: Separation
As you can see, our boids are great at sticking together. Unfortunately, they are not great at avoiding collisions with one another. As our second rule, let's ensure that boids try to avoid colliding by steering away from dangerously close boids.

Our implementation of <code>rule2()</code> will be almost identical to that of <code>rule1()</code>. The key differences are:

1. The boids don't need to look as far for boids they will collide with as they do for ones they need to join.
2. The boids should move away from potential collisions.
3. Avoiding collisions should take precedent over steering toward the group.

#####Look for danger!
As before, call <code>getBoidPositionsWithin(x:CGFloat, ofBoid:Boid)</code> on your delegate and assign the resulting list of boid positions to a variable. Define another variable at the top of Boid.Swift below your other constants with the line <code>let COLLIDE_DIS : CGFloat = 30</code> and use it in your call to the delegate method. Note that the collision distance is less than visible distance; as you tweak the values to your liking, remember that this inequality should always hold true. The resultant code should be as follows:

    let boidsTooClose = delegate.getBoidPositionsWithin(COLLIDE_DIS, ofBoid: self)

#####Avoid the collision
Call the method <code>vectorToCenterPointOf(points:[CGPoint])</code> on the array of neighbors you just found. However, this time you should steer the boid in the opposite direction of the vector you find. To do this, simply invert the sign of each vector component:

	var separationVector = vectorToCenterPointOf(boidsTooClose)
	separationVector = CGPoint(x:-separationVector.x,y:-separationVector.y)
	
#####Return the appropriate velocity
Define another CGFloat <code>SEPARATION</code> in the same place as all the others. Set it to 200 - doing so means that the resultant vector affects the boid 5 times the amount the cohesion vector does, meaning that avoiding collisions will take precedence over grouping. Return the vector as follows:
	
	return CGPoint(x: separationVector.x/SEPARATION, y: separationVector.y/SEPARATION)

Run your code again. Your boids should now be grouping, but keeping their spacing:

![](Assets/boidSeparation.gif)


###Rule 3: Alignment
Our boids are starting to come to life. They're aware of their neighbors as well as their neighbors' personal space. However, they seem to lack the drive to go anywhere. We'll change that by having each boid attempt to match its neighbors' velocities.

#####Find neighbors' velocities
Call <code>getBoidVelocitiesWithin(x:CGFloat, ofBoid:Boid)</code> on your delegate and assign the resulting list of boid velocities to a variable. Notice, this is a different method than we've used in the previous rules! It makes sense to use the same <code>VISIBLE_DIS</code> as the value for x. 

    let boidVelocities = delegate.getBoidVelocitiesWithin(VISIBLE_DIS, ofBoid:self)


#####Average the result
To find the average of a set of points, a helper method <code>avgOf(points:[CGPoint])</code> has been provided. Call this method on the velocities you found above:

	let alignmentVector = avgOf(boidVelocities)
	
#####Return the appropriate velocity
As before, define a new variable called <code>ALIGNMENT</code> and set it to 100. The result will be that your boids prioritize alignment with other boids over everything else, so they'll tend to _move_ as a group as opposed to focusing just on grouping.

    return CGPoint(x: alignmentVector.x / ALIGNMENT, y: alignmentVector.y / ALIGNMENT)


Congratulations! You've created swarm intelligence!
The coolest part aboud the boid AI is that you can add to it. Boids this simple are really only good for basic behaviors, but more complex

###Where to go from here
Congratulations!  The coolest part of swarm intellignece