# CloudResume

After achieving a few AWS certifications, I was looking for practical experience and decided to pursue the Cloud Resume Challenge. The challenge can be found here: https://cloudresumechallenge.dev/docs/the-challenge/aws/

There are 16 parts to the challenge that revolve around using AWS services

## CloudResume Challenge Steps Listed & Statuses
1. [Completed] Certification - Your resume needs to have the AWS Cloud Practitioner certification on it. This is an introductory certification that orients you on the industry-leading AWS cloud – if you have a more advanced AWS cert, that’s fine but not expected. You can sit this exam online for $100 USD. A Cloud Guru offers exam prep resources.

2. [Completed] HTML - Your resume needs to be written in HTML. Not a Word doc, not a PDF. Here is an example of what I mean.

3. [Completed] CSS - Your resume needs to be styled with CSS. No worries if you’re not a designer – neither am I. It doesn’t have to be fancy. But we need to see something other than raw HTML when we open the webpage.

4. [Completed] Static Website - Your HTML resume should be deployed online as an Amazon S3 static website. Services like Netlify and GitHub Pages are great and I would normally recommend them for personal static site deployments, but they make things a little too abstract for our purposes here. Use S3.

5. [Completed] HTTPS - The S3 website URL should use HTTPS for security. You will need to use Amazon CloudFront to help with this.

6. [Completed] DNS - Point a custom DNS domain name to the CloudFront distribution, so your resume can be accessed at something like my-c00l-resume-website.com. You can use Amazon Route 53 or any other DNS provider for this. A domain name usually costs about ten bucks to register.

7. [Completed] Javascript - Your resume webpage should include a visitor counter that displays how many people have accessed the site. You will need to write a bit of Javascript to make this happen. Here is a helpful tutorial to get you started in the right direction.

8. [Completed] Database - The visitor counter will need to retrieve and update its count in a database somewhere. I suggest you use Amazon’s DynamoDB for this. (Use on-demand pricing for the database and you’ll pay essentially nothing, unless you store or retrieve much more data than this project requires.) Here is a great free course on DynamoDB.

9. [Completed] API - Do not communicate directly with DynamoDB from your Javascript code. Instead, you will need to create an API that accepts requests from your web app and communicates with the database. I suggest using AWS’s API Gateway and Lambda services for this. They will be free or close to free for what we are doing.

10. [Completed] Python - You will need to write a bit of code in the Lambda function; you could use more Javascript, but it would be better for our purposes to explore Python – a common language used in back-end programs and scripts – and its boto3 library for AWS. Here is a good, free Python tutorial.

11. [To-Do] Tests You should also include some tests for your Python code. Here are some resources on writing good Python tests.

12. [Completed] IaC - You should not be configuring your API resources – the DynamoDB table, the API Gateway, the Lambda function – manually, by clicking around in the AWS console. Instead, define them in an AWS Serverless Application Model (SAM) template and deploy them using the AWS SAM CLI. This is called “infrastructure as code” or IaC. It saves you time in the long run.

13. [Completed] Source Control - You do not want to be updating either your back-end API or your front-end website by making calls from your laptop, though. You want them to update automatically whenever you make a change to the code. (This is called continuous integration and deployment, or CI/CD.) Create a GitHub repository for your backend code.

14. [In-Progress] CI/CD (Back end) - You do not want to be updating either your back-end API or your front-end website by making calls from your laptop, though. You want them to update automatically whenever you make a change to the code. (This is called continuous integration and deployment, or CI/CD.) Create a GitHub repository for your backend code

15. [To-Do] CI/CD (Front end) - Set up GitHub Actions such that when you push an update to your Serverless Application Model template or Python code, your Python tests get run. If the tests pass, the SAM application should get packaged and deployed to AWS.

16. [To-Do] Blog post - Finally, in the text of your resume, you should link a short blog post describing some things you learned while working on this project. Dev.to or Hashnode are great places to publish if you don’t have your own blog.
And that’s the gist of it! For strategies, tools, and further challenges to help you get hired in cloud, check out the AWS edition of the Cloud Resume Challenge book.