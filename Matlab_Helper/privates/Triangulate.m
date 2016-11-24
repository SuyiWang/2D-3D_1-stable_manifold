function [] = Triangulate( filename, fill )
    %%  Triangulate - 0) do not fill the cube; 1) fill the cube interier with a tetrahedron
    fprintf('Trianguating...');
    if fill
        disp('with filled interior');
        system('./triangulate 1');
    else
        disp('with unfilled interior');
        system('./triangulate 0');
    end

    
    %%  Load output
    fprintf('Reading Vertices...\n');
    fp = fopen('vert.bin','r');
    vert = fread(fp, [4 inf], 'double')';
    fclose(fp);
    
    
    fprintf('Reading Edges...\n');
    fp = fopen('edge.bin','r');
    edge = fread(fp, [2 inf], 'int32')';
    fclose(fp);
    
    
    fprintf('Processing Edges...\n');
    len = length(vert);    
    if size(edge,1) ~= 0
        tmpgraph = sparse(edge(:,1),edge(:,2),ones(length(edge),1), len, len);
    else
        warning('no edges, skipped');
        return;
    end
    tmpgraph = tmpgraph + tmpgraph';
    [I J K] = find(triu(tmpgraph));
    edge = [I J];
    clear I; clear J; clear K;clear tmpgraph;
    
    fprintf('Reading Triangles...\n');
    fp = fopen('triangle.bin','r');
    triangles = fread(fp, [3 inf], 'int32')';
    fclose(fp);
    
    
    % fprintf('Reading Tetrahedrons...\n');
    % fp = fopen('tetrahedron.bin','r');
    % tet = fread(fp, [4 inf], 'int32')';
    % fclose(fp);
    
    
    %%  Write input file for discrete morse
    %   edges and triangles are originally using vertex index starting from 1.
    fprintf('Writing simplices...\n');
    write_output(filename,vert, edge-1, triangles-1);
    % write_tetra([filename 'tet_'], vert, tet - 1);
    fprintf('All done!\n');
end

