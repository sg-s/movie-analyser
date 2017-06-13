%% movieAnalyser.m
% a barebones MATLAB class to boostrap your image analysis problem
% usage:
% 
% 1. 

classdef movieAnalyser < handle

	properties
		ui_handles
		plot_handles
		path_name
		current_frame = 1;
		current_raw_frame 			% stores the raw image of the current working frame
		nframes
		variable_name = 'frames';
		median_start = 1;
		median_stop = Inf;
		median_step = 25; % frames
		median_frame
		subtract_median = true;
	end

	methods
		function m = createGUI(m)
			m.ui_handles.fig = figure('NumberTitle','off','MenuBar','none','ToolBar','figure','CloseRequestFcn',@m.quitMovieAnalyser); hold on;
			m.ui_handles.fig.Tag = 'movieAnalyser';
			m.ui_handles.fig.Position(3) = 1280;
			m.ui_handles.fig.Position(4) = 800;
			
			m.ui_handles.pause_button = uicontrol('Units','normalized','Position',[.45 .01 .1 .05],'String','Play','Style','togglebutton','Value',1,'Callback',@m.togglePlay);
			m.ui_handles.next_button = uicontrol('Units','normalized','Position',[.55 .01 .1 .05],'String','>','Style','togglebutton','Value',1,'Callback',@m.nextFrame);
			m.ui_handles.prev_button = uicontrol('Units','normalized','Position',[.35 .01 .1 .05],'String','<','Style','togglebutton','Value',1,'Callback',@m.prevFrame);
			
			% make a scrubber
			m.ui_handles.scrubber = uicontrol('Units','normalized','Style','slider','Position',[0 0.09 1 .01],'Parent',m.ui_handles.fig,'Min',1,'Max',m.current_frame+1,'Value',m.current_frame,'SliderStep',[.01 .02],'BusyAction','cancel','Interruptible','off');
			addlistener(m.ui_handles.scrubber,'ContinuousValueChange',@m.scrubberCallback);

			m.plot_handles.ax = gca;
			m.plot_handles.ax.Position = [0.01 0.15 0.99 0.85];
			m.plot_handles.im = imagesc([0 0; 0 0]);


			% if path_name is set, operate on frame
			if ~isempty(m.path_name)
				m.ui_handles.scrubber.Max = m.nframes;
				operateOnFrame(m,[],[]);
			end

			axis tight
			axis equal

		end % end createGUI function
		
		function m = scrubberCallback(m,src,event)
			m.current_frame = ceil(m.ui_handles.scrubber.Value);
		end

		function m = set.current_frame(m,value)
			m.current_frame = value;
			operateOnFrame(m);
		end % end set current_frame

		function m = set.path_name(m,value)
			% ~~~~~~~ change me if your data is not a MAT file ~~~~~~~~~~~~~~~~~
			% verify it is there
			if isa(value,'matlab.io.MatFile')
			else
				assert(exist(value,'file') == 2,'File not found at location! Make sure you supply a path to a file.')
				m.path_name = matfile(value);
			end
			m.path_name.Properties.Writable = true;

			% figure out how many frames there are
			[~,~,m.nframes] = size(m.path_name,m.variable_name);

			%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		end % end set path_name


		function m = nextFrame(m,src,event)
			if m.current_frame < m.nframes
				m.current_frame = m.current_frame + 1;
			end
		end

		function m = prevFrame(m,src,event)
			if m.current_frame > 1
				m.current_frame = m.current_frame - 1;
			end
		end

		function m = operateOnFrame(m,src,event)
			%% ~~~~~~~~~ redefine this method in your class ~~~~~~~~~~~~~~~
			%% what you probably want to do is first call the method from the superclass (movieAnalyser), and then redefine this function in your subclass
			% see this link for more information:
			% https://www.mathworks.com/help/matlab/matlab_oop/modifying-superclass-methods-and-properties.html
			% 

			% read frame
			m.current_raw_frame = m.path_name.(m.variable_name)(:,:,m.current_frame);


			% subtract median if necessary 
			if m.subtract_median & ~isempty(m.median_frame)
				m.current_raw_frame = m.current_raw_frame - m.median_frame;
			end

			if isfield(m.plot_handles,'ax')
				if ~isempty(m.plot_handles.ax)
					m.plot_handles.im.CData = m.current_raw_frame;
					m.ui_handles.fig.Name = ['Frame # ' oval(m.current_frame)];
					
				end
			end
			
		end

		function m = togglePlay(m,src,event)
			if strcmp(src.String,'Play')
				src.String = 'Pause';
				% now loop through all frames
				for i = m.current_frame:m.nframes
					m.current_frame  = i;
					m.ui_handles.scrubber.Value = i;
					if strcmp(src.String,'Pause')
						operateOnFrame(m,src,event);
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
			fn = fieldnames(m.ui_handles);
			for i = 1:length(fn)
				try
					delete(m.ui_handles.(fn{i}))
				catch
				end
				m.ui_handles.(fn{i}) = [];
			end
			fn = fieldnames(m.plot_handles);
			for i = 1:length(fn)
				try
					delete(m.plot_handles.(fn{i}))
				catch
				end
				m.plot_handles.(fn{i}) = [];
			end
		end

		function m = testReadSpeed(m)
			% do a sequential read test
			m.current_frame = 1;
			tic;
			for i = 1:m.nframes
				m.current_frame = i;
				operateOnFrame(m,[],[]);
				t = toc;
				if t > 2
					break
				end
			end
			t = toc;
			disp([ oval(i) ' frames read in ' oval(t) ' seconds.'])
		end

		function m = computeMedianFrame(m)
			a = m.median_start;
			z = min([m.median_stop m.nframes]);

			% figure out the class of the matrix
			dets = whos(m.path_name);
			M = zeros(size(m.path_name,m.variable_name,1),size(m.path_name,m.variable_name,2),length(a:m.median_step:z),dets(find(strcmp(m.variable_name, {dets.name}))).class);

			% read frames
			read_these_frames = a:m.median_step:z;
			for i = 1:length(read_these_frames)
				cf = read_these_frames(i);
				M(:,:,i) = m.path_name.(m.variable_name)(:,:,cf); % this is 10X faster than a direct assignation; don't drink from the for-loops-are-bad-kool-aid font
			end
			m.median_frame = median(M,3);


		end % end computeMedianFrame

	end % end all methods
end	% end classdef


