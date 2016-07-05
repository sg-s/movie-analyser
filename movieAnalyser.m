%% movieAnalyser.m
% a barebones MATLAB class to boostrap your image analysis problem
% usage:
% 
% 1. 

classdef movieAnalyser < handle

	properties
		handles
		path_name
		current_frame = 1;
		current_raw_frame 			% stores the raw image of the current working frame
		nframes
		variable_name = 'frames';
	end

	methods
		function m = createGUI(m)
			m.handles.fig = figure('NumberTitle','off','MenuBar','none','ToolBar','figure','CloseRequestFcn',@m.quitMovieAnalyser); hold on;
			m.handles.fig.Tag = 'movieAnalyser';
			m.handles.fig.Position(3) = 1280;
			m.handles.fig.Position(4) = 800;
			m.handles.ax = gca;
			m.handles.pause_button = uicontrol('Units','normalized','Position',[.45 .01 .1 .05],'String','Play','Style','togglebutton','Value',1,'Callback',@m.togglePlay);
			m.handles.next_button = uicontrol('Units','normalized','Position',[.55 .01 .1 .05],'String','>','Style','togglebutton','Value',1,'Callback',@m.nextFrame);
			m.handles.prev_button = uicontrol('Units','normalized','Position',[.35 .01 .1 .05],'String','<','Style','togglebutton','Value',1,'Callback',@m.prevFrame);
			m.handles.ax.Position = [0.01 0.15 0.99 0.85];

			m.handles.im = imagesc([0 0; 0 0]);

			% make a scrubber
			m.handles.scrubber = uicontrol('Units','normalized','Style','slider','Position',[0 0.09 1 .01],'Parent',m.handles.fig,'Min',1,'Max',m.current_frame+1,'Value',m.current_frame,'SliderStep',[.01 .02],'BusyAction','cancel','Interruptible','off');
			addlistener(m.handles.scrubber,'ContinuousValueChange',@m.scrubberCallback);


			% if path_name is set, operate on frame
			if ~isempty(m.path_name)
				m.handles.scrubber.Max = m.nframes;
				m.operateOnFrame;
			end

			axis tight
			axis equal

		end % end createGUI function
		
		function m = scrubberCallback(m,~,~)
			m.current_frame = ceil(m.handles.scrubber.Value);
			m.operateOnFrame;
		end

		function m = set.path_name(m,value)
			% ~~~~~~~ change me if your data is not a MAT file ~~~~~~~~~~~~~~~~~
			% verify it is there
			if isa(value,'matlab.io.MatFile')
			else
				assert(exist(value,'file') == 2,'Expected a file path!')
				m.path_name = matfile(value);
			end
			m.path_name.Properties.Writable = true;

			% figure out how many frames there are
			[~,~,m.nframes] = size(m.path_name,m.variable_name);

			%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		end % end set path_name


		function m = nextFrame(m,~,~)
			if m.current_frame < m.nframes
				m.current_frame = m.current_frame + 1;
			end
			m.operateOnFrame;
		end

		function m = prevFrame(m,~,~)
			if m.current_frame > 1
				m.current_frame = m.current_frame - 1;
			end
			m.operateOnFrame;
		end

		function m = operateOnFrame(m,~,~)
			%% ~~~~~~~~~ redefine this method in your class ~~~~~~~~~~~~~~~
			%% what you probably want to do is first call the method from the superclass (movieAnalyser), and then redefine this function in your subclass
			% see this link for more information:
			% https://www.mathworks.com/help/matlab/matlab_oop/modifying-superclass-methods-and-properties.html
			% 

			% read frame
			eval(['m.current_raw_frame = m.path_name.' m.variable_name '(:,:,m.current_frame);']);

			if isfield(m.handles,'ax')
				if ~isempty(m.handles.ax)
					% cla(m.handles.ax)
					% imagesc(m.current_raw_frame);
					m.handles.im.CData = m.current_raw_frame;
					m.handles.fig.Name = ['Frame # ' oval(m.current_frame)];
					
				end
			end
			
		end

		function m = togglePlay(m,src,~)
			if strcmp(src.String,'Play')
				src.String = 'Pause';
				% now loop through all frames
				for i = m.current_frame:m.nframes
					m.current_frame  = i;
					m.handles.scrubber.Value = i;
					if strcmp(src.String,'Pause')
						m.operateOnFrame;
						drawnow limitrate
					else
						break
					end
				end
			elseif strcmp(src.String,'Pause')
				src.String = 'Play';
			end

		end % end toggle play

		function m = quitMovieAnalyser(m,~,~)
			% clear all handles
			fn = fieldnames(m.handles);
			for i = 1:length(fn)
				try
					delete(getfield(m.handles,fn{i}))
				catch
				end
				m.handles = setfield(m.handles,fn{i},[]);
			end
		end

		function m = testReadSpeed(m)
			% do a sequential read test
			m.current_frame = 1;
			a = 1;
			z = min([m.nframes 100]);
			tic;
			for i = a:z
				m.current_frame = i;
				m.operateOnFrame;
			end
			t = toc;
			disp([ oval(z-a) ' frames read in ' oval(t) ' seconds.'])
		end

	end% end all methods
end	% end classdef


