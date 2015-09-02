# rikc
Racker Interactive Knife Console

#### Usage

    # opens rikc console
    $> ./rikc.rb
    RIKC none >
    
    # setup customer
    RIKC none > create customer1
    
    # list customers
    RICK none > customers
    customer1
    customer2
    customer3
    
    # select/change customer
    RIKC none > use customer1
    RIKC customer1 > 
    
    # list customers nodes
    RIKC customer1 > nodes
    node1, 123.123.123.123
    node2, 234.234.234.234
    
    # show node details
    RIKC customer1 > info node1
        ip: 123.123.123.123
        run_list: recipe1, recipe2 ...
        
    
    # login to customer node
    RIKC customer1 > login node1
    user@node1 $: exit 
    
    # list customer environments
    RIKC customer1 > envs
    staging, 5 nodes
    production, 50 nodes
    
    # show environment details
    RIKC customer1 > info staging
        # of nodes: 50
        pinning: recipes: {'uno', 'dos'... }

     # list cookbooks on customer server
     RIKC customer1 > cookbooks
         cookbook1 : 0.0.1 0.0.2
         cookbook2 : 0.0.1 0.0.2
         ...

    # diff cookbooks from chef server and github repo
    RIKC customer1 > diff customer-cookbook {save}
    	diff output to file if save specified
    	streamed to console otherwise
        
    
    
    
    

