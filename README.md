# movieAnalyzer

a MATLAB class to help you bootstrap your image analysis problem.

## The problem

1. Writing GUIs is a pain. 
2. In most image(movie) analysis problems, you typically operate frame by frame, and you want to see how your algorithm performs
3. your algorithm makes a mistake. Quick -- which frame did if break down at? Wouldn't it be great to go back one frame?
4. Damn it, the code is still running! I want to pause it, to debug the problem frame.

## The solution 

`movieAnalyzer` is a barebones MATLAB class that, at its very minimum, acts as a horribly slow movie player. But the nice thing is that it comes with a `pause` button, as well as `next` and `previous` buttons. Drop your image analysis code in the region indicated, and suddenly you've got a way to step through your horribly complicated image analysis pipeline, and even go back in time. 

Debugging got a lot simpler, and you can spend more time writing actually useful code. 


# License 

data-manager is free software. 
[GPL v3](https://www.gnu.org/licenses/gpl-3.0.txt)
