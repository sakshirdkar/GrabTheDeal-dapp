# grab_the_deal_erc_20_token

# Token and its working:
Here token can be considered as any product. Let us assume token to
be a COVID-vaccine. <br> 
The seller will have some predefined supply of vaccines and can also add more
stock(tokens). <br> 
The customers will express the interest in the product and that is all they have to
do. <br> 
All the customers will be maintained in a queue internally in the order in which
they have expressed their interest. <br> 
When the seller is ready he will initiate the selling. The customers will be popped
out from the queue one by one and then the token is transferred to each customer
(There are appropriate checks for queue length and the stock. For example if there
are 150 customers in the queue and only 100 vaccines are available, vaccines will be
sent to top 100 customers and 50 customers will be left in the queue. They will be
supplied with vaccines when the new stock arrives.) <br> 
Once the initiate selling is completed, the tokens balance will be updated on both
the seller and the customer end and you can check the same in getBalance section of
the deployed contract.
