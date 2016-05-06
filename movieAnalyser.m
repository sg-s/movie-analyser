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
		nframes
	end

	methods
		function m = createGUI(m)
			m.handles.fig = figure('PaperUnits','points','PaperSize',[900 900],'NumberTitle','off','MenuBar','none','ToolBar','figure','CloseRequestFcn',@m.quitMovieAnalyser); hold on;
			m.handles.fig.Tag = 'movieAnalyser';
			m.handles.fig.Position(3) = 1280;
			m.handles.fig.Position(4) = 800;
			m.handles.ax = gca;
			m.handles.pause_button = uicontrol('Units','normalized','Position',[.45 .01 .1 .05],'String','Play','Style','togglebutton','Value',1,'Callback',@m.togglePlay);
			m.handles.next_button = uicontrol('Units','normalized','Position',[.55 .01 .1 .05],'String','>','Style','togglebutton','Value',1,'Callback',@m.nextFrame);
			m.handles.next_button = uicontrol('Units','normalized','Position',[.35 .01 .1 .05],'String','<','Style','togglebutton','Value',1,'Callback',@m.prevFrame);
			m.handles.ax.Position = [0.01 0.1 0.99 0.9];

			% if path_name is set, load the image
			if ~isempty(m.path_name)
				m.operateOnFrame;
			end

			axis tight
			axis equal

		end % end createGUI function
		
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
			[~,~,m.nframes] = size(m.path_name,'images');

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

		function m = operateOnFrame(m)
			%% ~~~~~~~~~ redefine this method in your class ~~~~~~~~~~~~~~~
			imagesc(m.path_name.images(:,:,m.current_frame));
			m.handles.fig.Name = ['Frame # ' oval(m.current_frame)];
			drawnow
		end

		function m = togglePlay(m,src,~)
			if strcmp(src.String,'Play')
				src.String = 'Pause';
				% now loop through all frames
				for i = m.current_frame:m.nframes
					m.current_frame  = i;
					if strcmp(src.String,'Pause')
						m.operateOnFrame;
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

	end% end all methods
end	% end classdef


