function consumption_savings_3d(testDir)
% CONSUMPTION_SAVINGS_3D  Classroom demo of the two-period consumer in 3-D.
%
%   max  1/2 log(C1) + 1/2 log(C2)
%   s.t. C1 + S = Y1,   C2 = Y2 + r S      (r = gross real interest rate)
%   =>   C1 + C2/r = Y1 + Y2/r,   so  C1* = (Y1 + Y2/r)/2,  C2* = r C1*
%
% Run with no arguments. Use "Next" / "Back" to walk through the stages, or
% drive it by hand: drag the 3-D plot to rotate it, move the r / azimuth /
% elevation sliders, and toggle layers with the checkboxes. "Stop" halts
% any animation.
%
% consumption_savings_3d(folder) renders each stage to PNGs in that folder
% without animating (used for testing).

Y1 = 1.5; Y2 = 0.5; r = 1;                % endowment and starting interest rate
rRange = [0.4 2];
cmax = 3.6; zmin = -2.5; zmax = 1.5;      % plot window
camZoom = 11;                             % camera view angle: larger = smaller plot
u = @(c1,c2) 0.5*log(c1) + 0.5*log(c2);
[C1,C2] = meshgrid(cmax*linspace(0.07,1,220).^1.6);   % denser grid near the axes
U = u(C1,C2); U(U < zmin) = NaN;
levels = -2:0.25:1.25;
testing = nargin > 0;
stopReq = false; busy = false; stage = 1;

stages = { ...
  '1. The budget set'
  '2. Twist it: the budget line is a wall'
  '3. The utility function u(C1, C2)'
  '4. Level sets of u = indifference curves'
  '5. Put them together'
  '6. The constrained maximum'
  '7. Look straight at the budget "wall"'
  '8. Change the interest rate'};

% ---------- figure and axes ----------
fig = figure('Name','Consumption-savings in 3-D','Color','w','Units','normalized', ...
    'Position',[.04 .06 .92 .86],'NumberTitle','off');
if testing, fig.Visible = 'off'; end
ax = axes(fig,'Position',[.06 .22 .56 .68]); hold(ax,'on'); grid(ax,'on'); box(ax,'on');
axis(ax,[0 cmax 0 cmax zmin zmax]); clim(ax,[zmin zmax]); colormap(ax,parula);
xlabel(ax,'C_1 (today)'); ylabel(ax,'C_2 (tomorrow)'); zlabel(ax,'utility');
ax.FontSize = 15; daspect(ax,[1 1 1.1]);
ax.CameraViewAngleMode = 'manual'; ax.CameraViewAngle = camZoom;   % fixed zoom: no resizing while rotating
hTitle = uicontrol(fig,'Style','text','Units','normalized','Position',[.04 .93 .58 .05], ...
    'FontSize',20,'FontWeight','bold','BackgroundColor','w');
pnl = uipanel(fig,'Position',[0 0 .64 .19],'BorderType','none','BackgroundColor','w');

ax2 = axes(fig,'Position',[.68 .47 .29 .45]); hold(ax2,'on'); box(ax2,'on');
axis(ax2,[0 cmax 0 cmax]); axis(ax2,'square'); ax2.FontSize = 13;
xlabel(ax2,'C_1'); ylabel(ax2,'C_2'); title(ax2,'The usual 2-D picture');
contour(ax2,C1,C2,U,levels,'Color',[.82 .82 .82]);

% ---------- objects that never move ----------
hIn  = surf(ax,C1,C2,U,'EdgeColor','none','FaceAlpha',.9);    % feasible part
hOut = surf(ax,C1,C2,U,'EdgeColor','none','FaceAlpha',.9);    % infeasible part
hLevS = gobjects(0); hLevF = gobjects(0);
M = contourc(C1(1,:),C2(:,1),U,levels); k = 1;
while k < size(M,2)
    lev = M(1,k); n = M(2,k); xy = M(:,k+1:k+n); k = k+n+1;
    hLevS(end+1) = plot3(ax,xy(1,:),xy(2,:),lev+0*xy(1,:)+.01,'k','LineWidth',.8); %#ok<AGROW>
    hLevF(end+1) = plot3(ax,xy(1,:),xy(2,:),zmin+0*xy(1,:),'Color',[.45 .45 .45]); %#ok<AGROW>
end
hEnd = plot3(ax,Y1,Y2,zmin,'ko','MarkerFaceColor','k','MarkerSize',8);
plot(ax2,Y1,Y2,'ko','MarkerFaceColor','k');
tx = Y1+.8; ty = Y2+1.1;                                    % label position, up and to the right
quiver(ax2,tx,ty-.06,Y1+.06-tx,Y2+.07-(ty-.06),0,'k','LineWidth',1.3,'MaxHeadSize',.6);
text(ax2,tx,ty,'endowment (Y_1, Y_2)','FontSize',12,'HorizontalAlignment','center','VerticalAlignment','bottom');

% ---------- objects that move with r ----------
hFeas  = patch(ax,nan,nan,nan,[.55 .75 1],'FaceAlpha',.55,'EdgeColor','none');
hBL    = plot3(ax,nan,nan,nan,'b','LineWidth',3);
hWall  = patch(ax,nan,nan,nan,[.25 .25 .9],'FaceAlpha',.18,'EdgeColor',[.25 .25 .9],'LineWidth',1.5);
hRidge = plot3(ax,nan,nan,nan,'r','LineWidth',4);
hICs   = plot3(ax,nan,nan,nan,'Color',[.85 0 0],'LineWidth',2);
hICf   = plot3(ax,nan,nan,nan,'Color',[.85 0 0],'LineWidth',2);
hStem  = plot3(ax,nan,nan,nan,'r--','LineWidth',1.5);
hOpt   = plot3(ax,nan,nan,nan,'ro','MarkerFaceColor','r','MarkerSize',11);
hOptF  = plot3(ax,nan,nan,nan,'ro','MarkerFaceColor','r','MarkerSize',8);
h2Feas = patch(ax2,nan,nan,[.55 .75 1],'FaceAlpha',.55,'EdgeColor','none');
h2BL   = plot(ax2,nan,nan,'b','LineWidth',2.5);
h2IC   = plot(ax2,nan,nan,'r','LineWidth',2);
h2Opt  = plot(ax2,nan,nan,'ro','MarkerFaceColor','r','MarkerSize',8);
uistack(h2Feas,'bottom');

% ---------- controls ----------
ui = @(style,str,pos,varargin) uicontrol(fig,'Style',style,'String',str,'Units','normalized', ...
    'Position',pos,'FontSize',13,'BackgroundColor','w',varargin{:});
uiL = @(style,str,pos,varargin) uicontrol(pnl,'Style',style,'String',str,'Units','normalized', ...   % left panel
    'Position',[pos(1)/.64 pos(2)/.19 pos(3)/.64 pos(4)/.19],'FontSize',13,'BackgroundColor','w',varargin{:});
uiL('pushbutton','◀ Back',[.04 .12 .07 .05],'Callback',@(~,~) step(-1));
uiL('pushbutton','Next ▶',[.12 .12 .07 .05],'Callback',@(~,~) step(+1));
uiL('pushbutton','Stop',[.20 .12 .06 .05],'Callback',@(~,~) setStop(),'ForegroundColor',[.7 0 0]);
uiL('pushbutton','Rotate to wall view',[.28 .12 .12 .05],'Callback',@(~,~) animWall());
uiL('pushbutton','Spin 360°',[.41 .12 .08 .05],'Callback',@(~,~) animSpin());
uiL('pushbutton','Sweep r',[.50 .12 .07 .05],'Callback',@(~,~) animSweep());

uiL('text','interest rate r',[.04 .055 .1 .035],'HorizontalAlignment','left');
sR  = uiL('slider','',[.14 .06 .30 .03],'Min',rRange(1),'Max',rRange(2),'Value',r);
tR  = uiL('text','',[.45 .055 .06 .035],'HorizontalAlignment','left');
uiL('text','azimuth',[.04 .01 .1 .035],'HorizontalAlignment','left');
sAz = uiL('slider','',[.14 .015 .19 .03],'Min',-180,'Max',180,'Value',0);
uiL('text','elevation',[.35 .01 .07 .035],'HorizontalAlignment','left');
sEl = uiL('slider','',[.42 .015 .15 .03],'Min',-5,'Max',90,'Value',90);
addlistener(sR,'ContinuousValueChange',@(s,~) setR(s.Value));
addlistener(sAz,'ContinuousValueChange',@(~,~) handView());
addlistener(sEl,'ContinuousValueChange',@(~,~) handView());

names = {'Budget set','Utility surface','Infeasible part of surface','Level sets on surface', ...
         'Indifference curves (floor)','Budget wall','Constrained max'};
cb = gobjects(1,numel(names));
for i = 1:numel(names)
    cb(i) = ui('checkbox',names{i},[.68 .39-.042*(i-1) .2 .04],'Callback',@(~,~) applyVis());
end
cbTrack = ui('checkbox','Keep looking at the wall as r changes',[.68 .06 .29 .04]);
hInfo = ui('text','',[.68 .005 .3 .05],'HorizontalAlignment','left','FontSize',14);

rot = rotate3d(fig); setAllowAxesRotate(rot,ax2,false);
rot.ActionPostCallback = @(~,~) handRotated();
if ~testing, rot.Enable = 'on'; end

setR(r); goStage(1,false);
if ~testing, fig.WindowStyle = 'normal'; movegui(fig,'onscreen'); figure(fig); drawnow; end   % bring the window to the front

if testing                                     % render each stage without animation
    for s = 1:numel(stages)
        goStage(s,false); if s == 8, setR(1.8); end
        f = getframe(fig); imwrite(f.cdata,fullfile(testDir,sprintf('stage%d.png',s)));
    end
    view(ax,-120,35); syncSliders(); f = getframe(fig); imwrite(f.cdata,fullfile(testDir,'stage7_rotated.png'));
    close(fig);
end

% =================== nested functions ===================
    function setR(rNew)
        r = rNew; sR.Value = r;
        b1 = Y1 + Y2/r; b2 = r*Y1 + Y2;                 % intercepts of the budget line
        F = C2 <= b2 - r*C1;
        Zi = U; Zi(~F) = NaN; Zo = U; Zo(~(conv2(double(~F),ones(3),'same') > 0)) = NaN;  % overlap one cell: no seam
        set(hIn,'ZData',Zi); set(hOut,'ZData',Zo);
        set(hFeas,'XData',[0 b1 0],'YData',[0 0 b2],'ZData',zmin*[1 1 1]);
        set(hBL,'XData',[0 b1],'YData',[b2 0],'ZData',[zmin zmin]);
        set(hWall,'XData',[0 b1 b1 0],'YData',[b2 0 0 b2],'ZData',[zmin zmin zmax zmax]);
        c = linspace(.01,b1-.01,400); z = u(c,b2-r*c); z(z < zmin) = NaN;
        set(hRidge,'XData',c,'YData',b2-r*c,'ZData',z);
        c1s = b1/2; c2s = r*c1s; us = u(c1s,c2s);
        g = linspace(.02,cmax,400); ic = exp(2*us)./g; ic(ic > cmax) = NaN;
        set(hICs,'XData',g,'YData',ic,'ZData',us+0*g+.01);
        set(hICf,'XData',g,'YData',ic,'ZData',zmin+0*g);
        set(hOpt,'XData',c1s,'YData',c2s,'ZData',us);
        set(hStem,'XData',[c1s c1s],'YData',[c2s c2s],'ZData',[zmin us]);
        set(hOptF,'XData',c1s,'YData',c2s,'ZData',zmin);
        set(h2Feas,'XData',[0 b1 0],'YData',[0 0 b2]);
        set(h2BL,'XData',[0 b1],'YData',[b2 0]); set(h2IC,'XData',g,'YData',ic);
        set(h2Opt,'XData',c1s,'YData',c2s);
        tR.String = sprintf('%.2f',r);
        hInfo.String = sprintf('r = %.2f   C1* = %.2f   C2* = %.2f   S* = %.2f',r,c1s,c2s,Y1-c1s);
        if cbTrack.Value, view(ax,wallAz(),max(sEl.Value,0)); syncSliders(); end
    end

    function goStage(s,animate)
        if busy || s < 1 || s > numel(stages), return, end
        stage = s; hTitle.String = stages{s};
        %        budget surf  infeas levS  levF  wall  max
        V = [     1     0     0     0     0     1     0      % 1  (wall seen edge-on from above)
                  1     0     0     0     0     1     0      % 2
                  0     1     1     1     0     0     0      % 3
                  0     1     1     1     1     0     0      % 4
                  1     1     1     1     0     1     0      % 5
                  1     1     1     0     0     1     1      % 6
                  1     1     0     0     0     1     1      % 7
                  1     1     0     0     0     1     1 ];   % 8
        for i = 1:numel(cb), cb(i).Value = V(s,i); end
        hOut.FaceAlpha = 0.9 - 0.75*(s >= 5);           % fade the infeasible part once the budget appears
        cbTrack.Value = s >= 7;
        applyVis();
        views = [0 90; -37.5 30; -37.5 30; -37.5 30; -37.5 30; -50 28; NaN 4; NaN 4];
        az = views(s,1); el = views(s,2); if isnan(az), az = wallAz(); end
        if s == 8 && animate, animSweep(); return, end
        if animate, animView(az,el,1.5 + (s == 2)); else, view(ax,az,el); syncSliders(); end   % stage 2 twists slower
    end

    function wallCheck()           % seen exactly edge-on from overhead, the see-through wall draws stray lines on some GPUs
        [~,e] = view(ax);
        hWall.Visible = matlab.lang.OnOffSwitchState(cb(6).Value && e < 89);
    end

    function step(d)               % reads the current stage at click time
        goStage(stage+d,true);
    end

    function applyVis()
        onoff = @(h,v) set(h,'Visible',matlab.lang.OnOffSwitchState(v));
        onoff([hFeas hBL hEnd],cb(1).Value);
        onoff(hIn,cb(2).Value); onoff(hOut,cb(2).Value && cb(3).Value);
        onoff(hLevS,cb(4).Value); onoff(hLevF,cb(5).Value);
        wallCheck();
        onoff([hRidge hICs hICf hStem hOpt hOptF],cb(7).Value);
        onoff([h2IC h2Opt],cb(7).Value);
    end

    function a = wallAz()          % view direction perpendicular to the budget line, from outside
        a = atan2d(r,-1);
    end

    function handView()            % angle sliders moved: your angle wins over wall tracking
        cbTrack.Value = 0; view(ax,sAz.Value,sEl.Value);
    end

    function handRotated()         % mouse drag: same
        cbTrack.Value = 0; syncSliders();
    end

    function syncSliders()
        [a,e] = view(ax); sAz.Value = mod(a+180,360)-180; sEl.Value = min(max(e,-5),90);
        wallCheck();
    end

    function setStop(), stopReq = true; end

    function ok = startAnim()
        ok = ~busy; if ok, busy = true; stopReq = false; end
    end

    function animView(az1,el1,secs)
        if ~startAnim(), return, end
        [az0,el0] = view(ax); d = mod(az1-az0+180,360)-180; n = max(1,round(secs*30));
        for i = 1:n
            if stopReq || ~isvalid(fig), break, end
            t = (1-cos(pi*i/n))/2;
            view(ax,az0+t*d,el0+t*(el1-el0)); syncSliders(); drawnow; pause(1/30);
        end
        busy = false;
    end

    function animWall()
        cb(3).Value = 0; applyVis(); animView(wallAz(),4,2.5);
    end

    function animSpin()
        if ~startAnim(), return, end
        [az0,e] = view(ax);
        for a = az0:2:az0+360
            if stopReq || ~isvalid(fig), break, end
            view(ax,a,e); syncSliders(); drawnow; pause(1/40);
        end
        busy = false;
    end

    function animSweep()
        if ~startAnim(), return, end
        path = [linspace(r,0.6,40) linspace(0.6,2,90) linspace(2,1,50)];
        for x = path
            if stopReq || ~isvalid(fig), break, end
            setR(x); drawnow; pause(1/30);
        end
        busy = false;
    end
end
