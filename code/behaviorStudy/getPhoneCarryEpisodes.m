%It receives phone accelerometer-X data, and computes phone carry episodes
%phoneOnBodyEpisodes: [subjectID, day, starttime, endtime, 1=on-Body/0=off-body]

function [phoneOnEpisodes phoneOnBodyEpisodes phoneOffBodyEpisodes phoneOnDur phonOnBodyDur phoneOffBodyDur]=getPhoneCarryEpisodes(G, subject, day, timestamp,sample)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Copyright 2014 University of Memphis
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%
phoneOnBodyEpisodes=[];
phoneOffBodyEpisodes=[];
phoneOnDur=0;
phonOnBodyDur=0;
phoneOffBodyDur=0;
windowSize=2*60000;  %2 minutes window
phoneCarryVal=zeros(1,length(timestamp(1):windowSize:timestamp(end)));
phoneCarryTimestamp=-1*ones(1,length(timestamp(1):windowSize:timestamp(end)));
i=1;
for t=timestamp(1):windowSize:timestamp(end)
    ind=find(timestamp>=t & timestamp<=t+windowSize);
    if var(sample(ind))>16  %threshold for phone carry detection
        phoneCarryVal(i)=1;
    end
    phoneCarryTimestamp(i)=t;
    i=i+1;
end
figure;hold on;
  ylim([-2 2]);

phoneOnEpisodes=getEpisodesFromTimestamps(timestamp,10);   %return phone on episodes from the timestamps
r=size(phoneOnEpisodes,1);
for i=1:r
    phoneOnDur=phoneOnDur+(phoneOnEpisodes(i,2)-phoneOnEpisodes(i,1))/1000/60;
    plot_signal([convert_timestamp_matlabtimestamp(G,phoneOnEpisodes(i,1)) convert_timestamp_matlabtimestamp(G,phoneOnEpisodes(i,2))],[-0.5 -0.5 ],'k-',4);
end
phoneOnEpisodes=[subject*ones(r,1) day*ones(r,1) phoneOnEpisodes];

phoneCarryEpisodes.value=[];
phoneCarryEpisodes.starttime=[];
phoneCarryEpisodes.endtime=[];

% episodes=getEpisodesFromTimestamps(phoneCarryTimestamp,windowSize);
%merge for each episodes
now=0;
for p=1:size(phoneOnEpisodes,1)             %find phone carry episodes under phone ON episodes.
    inde=find(phoneCarryTimestamp>=phoneOnEpisodes(p,3) & phoneCarryTimestamp<=phoneOnEpisodes(p,4));
    len=length(inde);
    for i=1:len
        if i==1 || phoneCarryVal(inde(i)-1)~=phoneCarryVal(inde(i))
            now=now+1;
            phoneCarryEpisodes.starttime(now)=phoneCarryTimestamp(inde(i));
            phoneCarryEpisodes.value(now)=phoneCarryVal(inde(i));
        end
        phoneCarryEpisodes.endtime(now)=phoneCarryTimestamp(inde(i))+windowSize;
    end
end

for i=1:length(phoneCarryEpisodes.value)
    %plot each episodes
    if phoneCarryEpisodes.value(i)==1
        plot_signal([convert_timestamp_matlabtimestamp(G,phoneCarryEpisodes.starttime(i)) convert_timestamp_matlabtimestamp(G,phoneCarryEpisodes.endtime(i))],[phoneCarryEpisodes.value(i) phoneCarryEpisodes.value(i)],'g-',4);
        phoneOnBodyEpisodes=[phoneOnBodyEpisodes;subject day phoneCarryEpisodes.starttime(i) phoneCarryEpisodes.endtime(i)];
        phonOnBodyDur=phonOnBodyDur+(phoneCarryEpisodes.endtime(i)-phoneCarryEpisodes.starttime(i))/1000/60;
    else
        plot_signal([convert_timestamp_matlabtimestamp(G,phoneCarryEpisodes.starttime(i)) convert_timestamp_matlabtimestamp(G,phoneCarryEpisodes.endtime(i))],[phoneCarryEpisodes.value(i) phoneCarryEpisodes.value(i)],'r-',4);
        phoneOffBodyEpisodes=[phoneOffBodyEpisodes;subject day phoneCarryEpisodes.starttime(i) phoneCarryEpisodes.endtime(i)];
        phoneOffBodyDur=phoneOffBodyDur+(phoneCarryEpisodes.endtime(i)-phoneCarryEpisodes.starttime(i))/1000/60;
    end
end
end
