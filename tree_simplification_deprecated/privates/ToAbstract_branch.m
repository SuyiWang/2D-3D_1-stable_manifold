function [absG, edgeG, edgelist, abs_idx] = ToAbstract_branch(G, verbose, vert, opt)

if nargin == 3
    opt = 0;
end

fvalue = vert(:,4);
graph = G+G';
graph = graph - diag(diag(graph));
degcount = zeros(length(G), 1);
disp('counting degrees for each vertex');
for i = 1:length(G)
    nbvert = find(graph(i,:));
    degcount(i) = length(nbvert);
end
abs_idx = find(degcount>0 & degcount~=2);
rev_idx = ones(length(graph), 1) * (-1);
rev_idx(abs_idx) = 1:length(abs_idx);
absG = sparse(length(abs_idx), length(abs_idx));
edgeG = absG;

%% why the sum is odd number?
edgenum = sum(degcount(abs_idx));
edgelist = cell(edgenum, 1);
edgecount = 1;

rmvmark = zeros(length(G), 1);
edgeidx = zeros(length(G), 1);
edgetop = 1;

for i = 1:length(abs_idx)
    if rmvmark(abs_idx(i)) == 1
        % disp('There is something weird');
        continue;
    else
        rmvmark(abs_idx(i)) = 1;
    end
    list = find(graph(abs_idx(i),:));
    % should have 2 nb
    if length(list) == 2
        warning(['Found 2 neighbours for idx = ' int2str(i)]);
    end
    
    for j = 1:length(list)
        edgetop = 1;
        edgeidx(edgetop) = abs_idx(i);
        edgetop = edgetop + 1;
        flag = 0;

        while list(j) ~= -1
            nbvert = find(graph(list(j),:));
            if length(nbvert) > 2
                edgeidx(edgetop) = list(j);
                edgeidx(1:edgetop) = fliplr(edgeidx(1:edgetop)');
                edgetop = edgetop + 1;
                list(j) = -1;
                continue;
            elseif length(nbvert) == 1
                rmvmark(list(j)) = 1;
                if verbose
                    hold on;
                    plot3(vert(list(j),1),vert(list(j),2),vert(list(j),3),'r.');
                end
                edgeidx(edgetop) = list(j);
                edgeidx(1:edgetop) = fliplr(edgeidx(1:edgetop)');
                edgetop = edgetop + 1;
                list(j) = -1;
            else
                rmvmark(list(j)) = 1;
                edgeidx(edgetop) = list(j);
                edgetop = edgetop + 1;
                
                if (vert(list(j),1)==142 && vert(list(j), 2) == 248)
                    disp('');
                end

                if verbose
                    hold on;
                    plot3(vert(list(j),1),vert(list(j),2),vert(list(j),3),'r.');
                end
                if rmvmark(nbvert(1)) == 0
                    list(j) = nbvert(1);
                elseif rmvmark(nbvert(2)) == 0
                    list(j) = nbvert(2);
                else
                    flag = 1;
                    break;
                end
            end
        end

        edgetop = edgetop - 1;
        s = rev_idx(edgeidx(1));
        t = rev_idx(edgeidx(edgetop));
        if (flag)
            continue;
        elseif (s==-1 || t==-1)
            warning('something strange happened');
            continue;
        end
        edgelist{edgecount} = edgeidx(1:edgetop);

        edgeG(s, t) = edgecount;
        edgeG(t, s) = edgecount;
        if opt == 0 
            % maximum weight
            absG(s, t) = max(min(fvalue(edgelist{edgecount})), 1e-7);
            absG(t, s) = absG(s, t);
        elseif opt == 1
            % average weight
            absG(s, t) = avg_weight(fvalue(edgelist{edgecount}), ...
                                    vert(edgelist{edgecount}, 1:3));
            absG(t, s) = absG(s, t);
        elseif opt == 2
            absG(s, t) = max(fvalue(edgelist{edgecount})) - min(fvalue(edgelist{edgecount}));
            absG(t, s) = absG(s, t);
        end
        if absG(s,t) <1e-6
            warning('caught edge with 0 weight');
        end
        edgecount = edgecount + 1;
    end
end
