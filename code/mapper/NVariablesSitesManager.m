classdef NVariablesSitesManager < Mapper
  %NVARIABLESSITESMANAGER Maintains list of all sites. It is a slight 
  % generalization of SitesManager to n vector variables.
  %
  % Written by: Mateusz Malinowski
  % Email: m4linka@gmail.com
  % Created: 30.08.2010
  % 
  
  properties
    
    % contains sites
    sites
    
  end
  
  methods( Access = protected, Static )
    
    function newGradient = update_gradients( gradient1, gradient2 )
      len1 = length( gradient1 );
      len2 = length( gradient2 );
      
      if len1 ~= len2
        error('lengths don''t agree');
      end
      
      newGradient = cell( len1, 1 );
      
      for ii = 1:len1
        newGradient{ii} = gradient1{ii} + gradient2{ii};
      end
      
    end
    
  end
  
  methods
    
    function obj = NVariablesSitesManager( varargin )
      % Constructor.
      %
      % Params:
      %   varargin - mappers that we want to consider as one site
      %
      
      obj.sites = varargin;
      
    end
    
    function cat( obj, sitesManager )
      % Concatenates current sites manager with the new one.
      %
      % Params:
      %   sitesManager - sites manager to concatenate
      %
      
      obj.sites = cat( 2, obj.sites, sitesManager.sites );
      
    end
    
    function value = eval( obj, varargin)
      % Evaluates sites, that is if s1, s2, ..., sn are sites then
      % value = s1.eval + s2.eval + ... + sn.eval
      %
      % Params:
      %   latent variables
      %
      % Return:
      %   value - value of the sum of sites
      %
      
      value = 0;
      
      nSites = length( obj.sites );
      
      for ii = 1:nSites
        
        iSites = obj.sites{ ii };
        
        value = value + iSites.eval( varargin );
        
      end
      
    end
    
    function set_multiplier( obj, t )
      % Sets multiplier for all sites
      %
      % Params:
      %   t - multiplier to set
      %
      
      nSites = length( obj.sites );
      
      for ii = 1:nSites
        
        iSites = obj.sites{ ii };
        
        iSites.set_multiplier( t );
        
      end
      
    end
    
    
    function gradient = compute_gradient( obj, varargin )
      % Computes sum of sites' gradients, 
      % that is if s1, s2, ..., sn are sites then 
      % gradient = s1.gradient + s2.gradient + ... + sn.gradient
      %
      % Params:
      %   latent variables
      %
      % Return:
      %   gradient - collection of gradients (as cell array)
      %
      
      nSites = length( obj.sites );
      
      for ii = 1:nSites
        
        iSites = obj.sites{ ii };
        
        if ii == 1
          gradient = iSites.compute_gradient( varargin );
        else
          gradient = obj.update_gradients( ...
            gradient, iSites.compute_gradient( varargin ) );
        end
        
      end
      
    end
    
    function hessianV = compute_hessian( obj, varargin )
      % Computes Hessians of sites, 
      % that is if s1, s2, ..., sn are sites then
      % hessianV = s1.hessian * v + s2.hessian * v + ... + sn.hessian * V
      %
      % Params:
      %   latent variables
      %
      % Return:
      %   hessianV - hessian of sites multiply by vectors  (as cell array)
      %
      
      nSites = length( obj.sites );
      
      for ii = 1:nSites
        
        iSites = obj.sites{ ii };
        
        hessian = iSites.compute_hessian;    
              
        if ii == 1
          hessianV = hessian( varargin );
        else
          hessianV = obj.update_gradients( hessianV, hessian( varargin ) );
        end
        
      end
      
    end
    
  end
  
end

