function [D,n_steps] = dijks(A,s,t)
%DIJK Shortest paths from nodes 's' to nodes 't' using Dijkstra algorithm.
% [D, n_steps] = dijk(A,s,t)
%     A = n x n node-node weighted adjacency matrix of arc lengths
%         (Note: A(i,j) = 0   => Arc (i,j) does not exist;
%                A(i,j) = NaN => Arc (i,j) exists with 0 weight)
%     s = FROM node indices
%       = [] (default), paths from all nodes
%     t = TO node indices
%       = [] (default), paths to all nodes
%     D = |s| x |t| matrix of shortest path distances from 's' to 't'
%       = [D(i,j)], where D(i,j) = distance from node 'i' to node 'j'
%      n_steps = number of lines that connect two points
%
%	(If A is a triangular matrix, then computationally intensive node
%   selection step not needed since graph is acyclic (triangularity is a 
%   sufficient, but not a necessary, condition for a graph to be acyclic)
%   and A can have non-negative elements)
%
%	(If |s| >> |t|, then DIJK is faster if DIJK(A',t,s) used, where D is now
%   transposed and P now represents successor indices)
%
%  (Based on Fig. 4.6 in Ahuja, Magnanti, and Orlin, Network Flows,
%   Prentice-Hall, 1993, p. 109.
% Copyright (c) 1998-2000 by Michael G. Kay
% Matlog Version 1.3 29-Aug-2000
% 
%  Modified by JBT, Dec 2000, to delete paths
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction.
% The toolbox can be obtained from http://homepage.tudelft.nl/19j49
% You are free to use, change, or redistribute this code in any way you
% want for non-commercial purposes. However, it is appreciated if you 
% maintain the name of the original author.
%
% (C) Laurens van der Maaten, Delft University of Technology
     
% Modified by Rongrong Wang, Michigan State Univeristy

% Input Error Checking ******************************************************
error(nargchk(1,3,nargin));

[n,cA] = size(A);

if nargin < 2 | isempty(s), s = (1:n)'; else s = s(:); end
if nargin < 3 | isempty(t), t = (1:n)'; else t = t(:); end

if ~any(any(tril(A) ~= 0))			% A is upper triangular
   isAcyclic = 1;
elseif ~any(any(triu(A) ~= 0))	% A is lower triangular
   isAcyclic = 2;
else										% Graph may not be acyclic
   isAcyclic = 0;
end

if n ~= cA
   error('A must be a square matrix');
elseif ~isAcyclic & any(any(A < 0))
   error('A must be non-negative');
elseif any(s < 1 | s > n)
   error(['''s'' must be an integer between 1 and ',num2str(n)]);
elseif any(t < 1 | t > n)
   error(['''t'' must be an integer between 1 and ',num2str(n)]);
end
% End (Input Error Checking) ************************************************

A = A';		% Use transpose to speed-up FIND for sparse A

D = zeros(length(s),length(t));
P = zeros(length(s),n);

for i = 1:length(s)
   j = s(i);
   
   Di = Inf*ones(n,1); Di(j) = 0;
   
   isLab = logical(zeros(length(t),1));
   if isAcyclic ==  1
      nLab = j - 1;
   elseif isAcyclic == 2
      nLab = n - j;
   else
      nLab = 0;
      UnLab = 1:n;
      isUnLab = logical(ones(n,1));
   end
   steps = zeros(n,1);
   while nLab < n & ~all(isLab)
      if isAcyclic
         Dj = Di(j);
      else	% Node selection
         [Dj,jj] = min(Di(isUnLab));
         j = UnLab(jj);
         UnLab(jj) = [];
         isUnLab(j) = 0;
      end
      
      nLab = nLab + 1;
      if length(t) < n, isLab = isLab | (j == t); end
      
      [jA,kA,Aj] = find(A(:,j));
      Aj(isnan(Aj)) = 0;
            
      if isempty(Aj), Dk = Inf; else Dk = Dj + Aj; end
      
      P(i,jA(Dk < Di(jA))) = j;
      steps(jA(Dk==min(Di(jA),Dk)& Dk~=Inf)) = steps(j)+1;
      Di(jA) = min(Di(jA),Dk);
    
      
      if isAcyclic == 1			% Increment node index for upper triangular A
         j = j + 1;
      elseif isAcyclic == 2	% Decrement node index for lower triangular A
         j = j - 1;
      end
      
      %disp( num2str( nLab ));
   end
   D(i,:) = Di(t)';
   n_steps(:,i) = steps;
end
n_steps=n_steps';

