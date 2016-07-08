# movieAnalyser

a MATLAB class to help you bootstrap your image analysis problem.

## The problem

0. Movie files are massive, and computers (still) have puny RAM and slow I/O. 
1. Writing GUIs is a pain. 
2. In most image(movie) analysis problems, you typically operate frame by frame, and you want to see how your algorithm performs
3. your algorithm makes a mistake. Quick -- which frame did if break down at? Wouldn't it be great to go back one frame?
4. Damn it, the code is still running! I want to pause it, to debug the problem frame. Aargh!

## The solution 

`movieAnalyser` is a barebones MATLAB class that, in its simplest form, acts as a slick movie player. But the nice thing is that it comes with `pause`/`Play` buttons, as well as `next` and `previous` buttons. Write a class that inherits from `movieAnalyser`, where you do your tracking, and magically you've got a way to 

1. step through your horribly complicated image analysis pipeline one frame at a time
2. even go back in time one frame, interactively.
3. fall back to fast, headless tracking, without changing a single line of code when you finish debugging. 

Debugging got a lot simpler, and you can spend more time writing actually useful code. 

Since `movieAnalyser` inherits from the `handle` class in MATLAB, all `movieAnalyser` objects have two dual representations: as a GUI object that you can see, and also as a object in your workspace. Changes to the GUI reflect on the object in your workspace. You can switch effortlessly between the GUI and the command line. It's awesome. 


## Installation

The recommended way to install this is to use my package manager:

```matlab
urlwrite('http://srinivas.gs/install.m','install.m'); 
install movie-analyser
install srinivas.gs_mtools  
```

## Usage

### 1. build a interface to read your movie/data file

By default, `movieAnalyser` assumes your movies are HDF5 (.mat v7.3+) files with the images stored in a 3D matrix called `frames`. `movieAnalyser` uses `matfile` to speed up data reads. If your movie is in a 3D matrix with a different name, set the `variable_name` property correctly. 

If your movies are in a different format, you'll have to modify `movieAnalyser` so that it knows how to read frames off your movie.

### 2. add your tracking/analysis code 

`movieAnalyser` uses  `movieAnalyser.operateOnFrame` to read each image frame by frame. Simply add your code to that function and it will be called for each frame. Here is an example class that you can define that inherits from `movieAnalyser` and uses it:

```matlab

classdef superTrack < movieAnalyser

	properties
		% define your properties here
	end

	methods
		% define your methods here

		function obj = operateOnFrame(obj) 
			operateOnFrame@movieAnalyser(obj); % first call the method from the parent class

			% now insert your own code here. it will run on every frame. for example:
			obj = findSpaceships(obj);

			obj = findDeathStar(obj);
		end

	end

end
```

## Methods

- `createGUI` makes the GUI
- `testReadSpeed` determines the time to read a hundred frames. If this is very slow, you're not going to have a good time
- `computeMedianFrame` computes the median frame over some interval. Very useful in removing static backgrounds. 

## Limitations 

1. `movieAnalyser` is explicitly designed for tracking algorithms that operate frame by frame. Something more complicated is outside its use case.
2. `movieAnalyser` is capable only of playing back frames at a maximum speed of 20 frames per second, due to limitations in MATLAB's [graphics engine](https://www.mathworks.com/help/matlab/ref/drawnow.html)
3. When working with a matrix containing a movie in a matfile, you should not store any other variable in that matfile, especially nested structures. This slows down read speeds dramatically. 

# License 

movie-analyser is free software. 
[GPL v3](https://www.gnu.org/licenses/gpl-3.0.txt)
