classdef GetPoints < matlab.apps.AppBase
%
%   ABOUT: Opens up an image into a figure to allow interactive point
%   picking. Define control points for the plot axes limits, and add points
%   to the plot. An overlaid image is provided after each "Add Point" call
%   to provide immediate feedback on quality. Data can be output to the
%   console, workspace, or to a file. Basic checks are done for workspace
%   and file outputs.
%
%   Notes:
%   [1] Currently all key and mouse button presses are used to add data to
%   the x and y values. 
%
%   [2] Zooming can only be performed between different "Add Point" calls.
%  
%   [3] Control points must all be added in the same "Control Point" call.
% 

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        FileEditField            matlab.ui.control.EditField
        OpenFileButton           matlab.ui.control.Button
        XRangeEditFieldLabel     matlab.ui.control.Label
        XRangeEditField          matlab.ui.control.NumericEditField
        YRangeEditFieldLabel     matlab.ui.control.Label
        YRangeEditField          matlab.ui.control.NumericEditField
        XMaxEditField            matlab.ui.control.NumericEditField
        YMaxEditField            matlab.ui.control.NumericEditField
        XLogSwitchLabel          matlab.ui.control.Label
        XLogSwitch               matlab.ui.control.Switch
        YLogSwitchLabel          matlab.ui.control.Label
        YLogSwitch               matlab.ui.control.Switch
        ControlPointsButton      matlab.ui.control.Button
        AddPointsButton          matlab.ui.control.Button
        OutputCoordinatesButton  matlab.ui.control.Button
        DisplayinConsoleButton   matlab.ui.control.Button
        WritetoFileButton        matlab.ui.control.Button
        ClearPointsButton        matlab.ui.control.Button
    end


    properties (Access = private)
        fileName % This is the filename that will be used to open an image
        XMin     % Minimum value of x for plot
        XMax     % Maximum value of x for plot
        YMin     % Minimum value of y for plot
        YMax     % Maximum value of y for plot
        xc_p     % Control points for plot (X)
        yc_p     % Control points for plot (Y)
        XLog     % Toggle X axis logarithmic functions 
        YLog     % Toggle Y axis logarithmic functions 
        x_p      % Store the selected points x values 
        y_p      % Store the selected points y values 
        x        % Store the scaled points x values 
        y        % Store the scaled points y values 
        img      % Holds the image
        hndl     % Figure handle that supports regular figure callbacks (not UIFigure)
        ax       % Axes handle for figure;
        % Annotations for figure
        sc_p     % Scatter object for control points 
        l_p      % Line object for display points
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Basic initialization values 
            app.fileName = 'Click on the button to open an image';
            app.XMin = 0;
            app.XMax = 1;
            app.YMin = 0;
            app.YMax = 1;
            app.XLog = false;
            app.YLog = false;
            app.x_p = [];
            app.y_p = [];
            % Update fields after startup creation
            app.FileEditField.Value = app.fileName;
            
            %             % Remove a bunch of stuff from UIAxes
            %             title(app.UIAxes, []);
            %             xlabel(app.UIAxes, []);
            %             ylabel(app.UIAxes, []);
            %             app.UIAxes.XAxis.TickLabels = {};
            %             app.UIAxes.YAxis.TickLabels = {};
            
            % Display instructions at the begining 
                msgbox({"Select axes control points in order of [X0,Y0], [X1, Y0], [X1, Y1], [X0,Y1] (ccw from origin)";...
                "";...
                "Select points using 'Select Points'";...
                "";
                "Press enter/return when done selecting points";...
                "Remark: While Add Points is active, all key presses will add points to the plot"});
        end

        % Button pushed function: ControlPointsButton
        function ControlPointsButtonPushed(app, event)
            % Remove current control poitns if they exist 
            if ~isempty(app.sc_p)
                delete(findobj(gca,'type','scatter'));
            end
            
            % Get the control points 
            [app.xc_p,app.yc_p] = ginput(4);
            hold on;
            app.sc_p = scatter(app.ax, app.xc_p, app.yc_p,'MarkerEdgeColor','k','MarkerFaceColor','k');
            
            % Enable the select points button
            app.AddPointsButton.Enable = 'on';
        end

        % Button pushed function: DisplayinConsoleButton
        function DisplayinConsoleButtonPushed(app, event)
            % Update values in case anything has been toggled
            if app.XLog
            	app.x = log10(app.XMin) + (app.x_p-app.xc_p(1)) / (app.xc_p(2) - app.xc_p(1)) * (log10(app.XMax) - log10(app.XMin));
            else
            	app.x = app.XMin + (app.x_p-app.xc_p(1)) / (app.xc_p(2) - app.xc_p(1)) * (app.XMax - app.XMin);
            end
            
            
            if app.YLog
            	app.y = log10(app.YMin) + (app.y_p-app.yc_p(1)) / (app.yc_p(4) - app.yc_p(1)) * (log10(app.YMax) - log10(app.YMin));
            else
            	app.y = app.YMin + (app.y_p-app.yc_p(1)) / (app.yc_p(4) - app.yc_p(1)) * (app.YMax - app.YMin);
            end
            disp([app.x, app.y]);
            
        end

        % Value changed function: FileEditField
        function FileEditFieldValueChanged(app, event)
            value = app.FileEditField.Value;
            app.fileName = value;
        end

        % Button pushed function: OpenFileButton
        function OpenFileButtonPushed(app, event)
            [file,location] = uigetfile( ...
                                        {'*.png', 'PNG Files (*.png)';
                                          '*.jpeg;.jpg', 'JPEG Files (*.jpg, *.jpeg)';
                                          '*.*',  'All Files (*.*)'}, ...
                                           'Select a File');
            app.fileName = [location, file];
            app.FileEditField.Value = app.fileName;
            app.img = imread(app.fileName);
            app.hndl = figure;
            app.ax = gca;
            imshow(app.img, 'Parent', app.ax, 'InitialMagnification','fit');
            
            % Enable the control points button 
            app.ControlPointsButton.Enable = 'on';
            
        end

        % Button pushed function: OutputCoordinatesButton
        function OutputCoordinatesButtonPushed(app, event)
            % Update values in case anything has been toggled
            if app.XLog
            	app.x = log10(app.XMin) + (app.x_p-app.xc_p(1)) / (app.xc_p(2) - app.xc_p(1)) * (log10(app.XMax) - log10(app.XMin));
            else
            	app.x = app.XMin + (app.x_p-app.xc_p(1)) / (app.xc_p(2) - app.xc_p(1)) * (app.XMax - app.XMin);
            end
            
            if app.YLog
            	app.y = log10(app.YMin) + (app.y_p-app.yc_p(1)) / (app.yc_p(4) - app.yc_p(1)) * (log10(app.YMax) - log10(app.YMin));
            else
            	app.y = app.YMin + (app.y_p-app.yc_p(1)) / (app.yc_p(4) - app.yc_p(1)) * (app.YMax - app.YMin);
            end
            
            % Get text input from matlab window
            vname = inputdlg({'Enter variable name:'}, 'Input', [1 45], {'defaultOutputName'});
            
            % Verify its a valid name, otherwise convert it
            if ~isvarname(vname{1})
                outName = matlab.lang.makeValidName(vname{1});
                sprintf('Variable %s was not valid, renamed to %s', vname{1}, outName);
            else
                outName = vname{1};
            end
            
            assignin('base', outName, [app.x, app.y]);
        end

        % Button pushed function: AddPointsButton
        function AddPointsButtonPushed(app, event)
            % Remove current control poitns if they exist 
            if ~isempty(app.l_p)
                delete(findobj(gca,'type','line'));
            end
            
            [xp,yp] = ginput;
            app.x_p = [app.x_p; xp];
            app.y_p = [app.y_p; yp];
            hold on;
            app.l_p = plot(app.ax, app.x_p, app.y_p,'Color','r','LineStyle','-','Marker','x');
            
            % Enable output buttons
            app.OutputCoordinatesButton.Enable = 'on';
            app.WritetoFileButton.Enable = 'on';
            app.DisplayinConsoleButton.Enable = 'on';
            app.ClearPointsButton.Enable = 'on';

        end

        % Button pushed function: WritetoFileButton
        function WritetoFileButtonPushed(app, event)
            % Update values in case anything has been toggled
            if app.XLog
            	app.x = log10(app.XMin) + (app.x_p-app.xc_p(1)) / (app.xc_p(2) - app.xc_p(1)) * (log10(app.XMax) - log10(app.XMin));
            else
            	app.x = app.XMin + (app.x_p-app.xc_p(1)) / (app.xc_p(2) - app.xc_p(1)) * (app.XMax - app.XMin);
            end
            
            if app.YLog
            	app.y = log10(app.YMin) + (app.y_p-app.yc_p(1)) / (app.yc_p(4) - app.yc_p(1)) * (log10(app.YMax) - log10(app.YMin));
            else
            	app.y = app.YMin + (app.y_p-app.yc_p(1)) / (app.yc_p(4) - app.yc_p(1)) * (app.YMax - app.YMin);
            end
            
            % Get text input from matlab window
            vname = inputdlg({'Enter output csv name:'}, 'Input', [1 260], {'defaultOutputName'});
            
            [path,name,ext]= fileparts(vname{1});
            
            % Try to put the file path together            
            if and(isempty(path), isempty(ext))
                outName = ['./',name,'.csv'];
                fprintf('No path was entered, assuming current working directory\n.')
            elseif and(isempty(path), ~isempty(ext))
                outName = ['./',name];
                fprintf('No path was entered, assuming current working directory\n.')
            else
                % At this point its on the user im not doing error checking 
                outName = name;
            end
            
            % Use the java io to verify the file is writeable
            writefile = true;
            try
                java.io.File(outName).toPath;
            catch
                writefile = false;
                fprintf('The input file name is not able to be used as a file, no output was attempted.\n')
            end
            
            if writefile
                csvwrite(outName, [app.x, app.y]);
            end
        end

        % Value changed function: XLogSwitch
        function XLogSwitchValueChanged(app, event)
            switch app.XLogSwitch.Value
                case 'On'
                    app.XLog = true;
                case 'Off'
                    app.XLog = false;
            end
        end

        % Value changed function: XMaxEditField
        function XMaxEditFieldValueChanged(app, event)
            value = app.XMaxEditField.Value;
            app.XMax = value;
            if app.XMax <= app.XMin
                app.XMax = app.XMin + 1;
                app.XMaxEditField.Value = app.XMin + 1;
            end
        end

        % Value changed function: XRangeEditField
        function XRangeEditFieldValueChanged(app, event)
            value = app.XRangeEditField.Value;
            app.XMin = value;
            if app.XMin >= app.XMax
                app.XMin = app.XMax - 1;
                app.XRangeEditField.Value = app.XMax - 1;
            end
        end

        % Value changed function: YLogSwitch
        function YLogSwitchValueChanged(app, event)
            switch app.YLogSwitch.Value
                case 'On'
                    app.YLog = true;
                case 'Off'
                    app.YLog = false;
            end
        end

        % Value changed function: YMaxEditField
        function YMaxEditFieldValueChanged(app, event)
            value = app.YMaxEditField.Value;
            app.YMax = value;
            if app.YMax <= app.YMin
                app.YMax = app.YMin + 1;
                app.YMaxEditField.Value = app.YMin + 1;
            end
        end

        % Value changed function: YRangeEditField
        function YRangeEditFieldValueChanged(app, event)
            value = app.YRangeEditField.Value;
            app.YMin = value;
            if app.YMin >= app.YMax
                app.YMin = app.YMax - 1;
                app.YRangeEditField.Value = app.YMax - 1;
            end
        end

        % Button pushed function: ClearPointsButton
        function ClearPointsButtonPushed(app, event)
            % Clears out all points that were selected
            app.x_p = [];
            app.y_p = [];
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 943 162];
            app.UIFigure.Name = 'UI Figure';

            % Create FileEditField
            app.FileEditField = uieditfield(app.UIFigure, 'text');
            app.FileEditField.ValueChangedFcn = createCallbackFcn(app, @FileEditFieldValueChanged, true);
            app.FileEditField.Position = [172 24 573 22];

            % Create OpenFileButton
            app.OpenFileButton = uibutton(app.UIFigure, 'push');
            app.OpenFileButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFileButtonPushed, true);
            app.OpenFileButton.Position = [42 24 100 22];
            app.OpenFileButton.Text = 'Open File';

            % Create XRangeEditFieldLabel
            app.XRangeEditFieldLabel = uilabel(app.UIFigure);
            app.XRangeEditFieldLabel.HorizontalAlignment = 'right';
            app.XRangeEditFieldLabel.Position = [42 118 53 15];
            app.XRangeEditFieldLabel.Text = 'X Range';

            % Create XRangeEditField
            app.XRangeEditField = uieditfield(app.UIFigure, 'numeric');
            app.XRangeEditField.ValueChangedFcn = createCallbackFcn(app, @XRangeEditFieldValueChanged, true);
            app.XRangeEditField.ValueDisplayFormat = '%.10G';
            app.XRangeEditField.Position = [110 114 100 22];

            % Create YRangeEditFieldLabel
            app.YRangeEditFieldLabel = uilabel(app.UIFigure);
            app.YRangeEditFieldLabel.HorizontalAlignment = 'right';
            app.YRangeEditFieldLabel.Position = [42 76 53 15];
            app.YRangeEditFieldLabel.Text = 'Y Range';

            % Create YRangeEditField
            app.YRangeEditField = uieditfield(app.UIFigure, 'numeric');
            app.YRangeEditField.ValueChangedFcn = createCallbackFcn(app, @YRangeEditFieldValueChanged, true);
            app.YRangeEditField.ValueDisplayFormat = '%.10G';
            app.YRangeEditField.Position = [110 72 100 22];

            % Create XMaxEditField
            app.XMaxEditField = uieditfield(app.UIFigure, 'numeric');
            app.XMaxEditField.ValueChangedFcn = createCallbackFcn(app, @XMaxEditFieldValueChanged, true);
            app.XMaxEditField.ValueDisplayFormat = '%.10G';
            app.XMaxEditField.Position = [222 114 100 22];
            app.XMaxEditField.Value = 1;

            % Create YMaxEditField
            app.YMaxEditField = uieditfield(app.UIFigure, 'numeric');
            app.YMaxEditField.ValueChangedFcn = createCallbackFcn(app, @YMaxEditFieldValueChanged, true);
            app.YMaxEditField.ValueDisplayFormat = '%.10G';
            app.YMaxEditField.Position = [222 72 100 22];
            app.YMaxEditField.Value = 1;

            % Create XLogSwitchLabel
            app.XLogSwitchLabel = uilabel(app.UIFigure);
            app.XLogSwitchLabel.HorizontalAlignment = 'center';
            app.XLogSwitchLabel.Position = [538.5 83 38 15];
            app.XLogSwitchLabel.Text = 'X-Log';

            % Create XLogSwitch
            app.XLogSwitch = uiswitch(app.UIFigure, 'slider');
            app.XLogSwitch.ValueChangedFcn = createCallbackFcn(app, @XLogSwitchValueChanged, true);
            app.XLogSwitch.Position = [535 113 45 20];

            % Create YLogSwitchLabel
            app.YLogSwitchLabel = uilabel(app.UIFigure);
            app.YLogSwitchLabel.HorizontalAlignment = 'center';
            app.YLogSwitchLabel.Position = [662 83 37 15];
            app.YLogSwitchLabel.Text = 'Y-Log';

            % Create YLogSwitch
            app.YLogSwitch = uiswitch(app.UIFigure, 'slider');
            app.YLogSwitch.ValueChangedFcn = createCallbackFcn(app, @YLogSwitchValueChanged, true);
            app.YLogSwitch.Position = [658 113 45 20];

            % Create ControlPointsButton
            app.ControlPointsButton = uibutton(app.UIFigure, 'push');
            app.ControlPointsButton.ButtonPushedFcn = createCallbackFcn(app, @ControlPointsButtonPushed, true);
            app.ControlPointsButton.Enable = 'off';
            app.ControlPointsButton.Position = [374 118 100 22];
            app.ControlPointsButton.Text = 'Control Points';

            % Create AddPointsButton
            app.AddPointsButton = uibutton(app.UIFigure, 'push');
            app.AddPointsButton.ButtonPushedFcn = createCallbackFcn(app, @AddPointsButtonPushed, true);
            app.AddPointsButton.Enable = 'off';
            app.AddPointsButton.Position = [374 90 100 22];
            app.AddPointsButton.Text = 'Add Points';

            % Create OutputCoordinatesButton
            app.OutputCoordinatesButton = uibutton(app.UIFigure, 'push');
            app.OutputCoordinatesButton.ButtonPushedFcn = createCallbackFcn(app, @OutputCoordinatesButtonPushed, true);
            app.OutputCoordinatesButton.Enable = 'off';
            app.OutputCoordinatesButton.Position = [779.5 112 121 22];
            app.OutputCoordinatesButton.Text = 'Output Coordinates';

            % Create DisplayinConsoleButton
            app.DisplayinConsoleButton = uibutton(app.UIFigure, 'push');
            app.DisplayinConsoleButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayinConsoleButtonPushed, true);
            app.DisplayinConsoleButton.Enable = 'off';
            app.DisplayinConsoleButton.Position = [779.5 72 121 22];
            app.DisplayinConsoleButton.Text = 'Display in Console';

            % Create WritetoFileButton
            app.WritetoFileButton = uibutton(app.UIFigure, 'push');
            app.WritetoFileButton.ButtonPushedFcn = createCallbackFcn(app, @WritetoFileButtonPushed, true);
            app.WritetoFileButton.Enable = 'off';
            app.WritetoFileButton.Position = [779.5 24 121 22];
            app.WritetoFileButton.Text = 'Write to File';

            % Create ClearPointsButton
            app.ClearPointsButton = uibutton(app.UIFigure, 'push');
            app.ClearPointsButton.ButtonPushedFcn = createCallbackFcn(app, @ClearPointsButtonPushed, true);
            app.ClearPointsButton.Enable = 'off';
            app.ClearPointsButton.Position = [374 62 100 22];
            app.ClearPointsButton.Text = 'Clear Points';
        end
    end

    methods (Access = public)

        % Construct app
        function app = GetPoints

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end