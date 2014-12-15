%FIGURE BUILDER

%%
%Input pairing plots

hF = figure();
set(hF,'Color',[0 0 0]);
spots = 12;
hSP = zeros(spots,1);
for m = 1:spots
   hSP(m) = subplot(spots,1,m);
   qplot(currentfile,m,xlims,'pA','',0,mode,0,gca);
end
ylims = get(hSP,'YLim');
globalmin = 0;
for n = 1:spots
   tracemin = ylims{n}(1);
   if tracemin < globalmin
      globalmin = tracemin;
   end
end
set(hSP(:),'YLim',[globalmin 5]);
for p = 1:spots
   apos = get(hSP(p),'Position');
   set(hSP(p),'Position',[apos(1),apos(2),apos(3),apos(4)+0.01]);
end
pstimulus(hSP(1),0.4004,4);
scalebar(hSP(spots),[10,100],{'ms','pA'},2,[0.6 .1])
for q = 1:spots
   apos = get(hSP(q),'Position');
   annotation('textbox','String',num2str(q),'Position',[apos(1)-0.01,apos(2)+0.05,0.2,0.05],...
		       'LineStyle','none','FontName','Helvetica','FontSize',22,...
			   'FontWeight','bold','FitBoxToText','on','Color',[0 1 0]);
end
set(hF,'Position',[0.5594 0.0759  0.15  0.84]);
