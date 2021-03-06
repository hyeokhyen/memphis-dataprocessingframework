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
if isempty(chestDiffInd)
    chestONepisodes=[pid,sid,int64(D.sensor{4}.timestamp(1)),int64(D.sensor{4}.timestamp(end))];
else
    for i=1:length(chestDiffInd)
        if i==1
            chestONepisodes=[chestONepisodes;pid,sid,int64(D.sensor{4}.timestamp(1)),int64(D.sensor{4}.timestamp(chestDiffInd(i)))];
        end
        if i==length(phoneDiffInd)
            chestONepisodes=[chestONepisodes;pid,sid,int64(D.sensor{4}.timestamp(chestDiffInd(i)+1)),int64(D.sensor{4}.timestamp(end))];
        end
        if i~=1 && i~=length(phoneDiffInd)
            chestONepisodes=[chestONepisodes;pid,sid,int64(D.sensor{4}.timestamp(chestDiffInd(i-1)+1)),int64(D.sensor{4}.timestamp(chestDiffInd(i)))];
        end
    end
end

fid1=fopen(['c:\DataProcessingFrameworkV2\data\memphis\report\chestSensorONepisodes_' num2str(pid) '_' strcat('s',num2str(sid','%02d')) '.csv'],'a');
line=[];
for i=1:size(chestONepisodes,1)
line=[num2str(chestONepisodes(i,1)) ',' num2str(chestONepisodes(i,2),'%02d') ',' num2str(chestONepisodes(i,3)) ',' num2str(chestONepisodes(i,4))];
fprintf(fid1,'%s',line);
fprintf(fid1,'\n');
end;
fclose(fid1);
