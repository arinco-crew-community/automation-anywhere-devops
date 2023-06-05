# Automation Anywhere DevOps
This blog explains how to setup an Azure DevOps Pipeline for moving bots from Development Control Room to UAT and Production for Automation Anywhere 360 which is Automation Anywhere cloud offering.

## What is Automation Anywhere
Automation Anywhere in very simple terms is an RBA which stands for Robotic Process Automation. It provides lots of tools to automate repetetive tasks. Automation Anywhere is a complex RBA provider among many others but detailing its functionalities is beyound the scope of the blog article.

If you like reading documentations, Automation Anywhere itself has a lot to say in [their docs](https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/product-feature-lifecycle/learn-overview.html)

If you enjoy watching video courses, I think for the most part the videos from Youtube have you covered, I have links to a number of them in [Additional Resources](#additional-resources) that you might want to check out

## DevOps vs BLM
BLM or Bot Life Cycle management is a separate topic from DevOps. In this blog the focus is on DevOps but just to make things a little bit clearer, Once you logged into Automation Anywhere Control Room, you can find a set of settings for `Remote Git Repository Integration`.

![Remote Git Repository Integration](RemoteGitRepoIntegration.png)


As for my exploration, `Remote Git Repository Integration` can be used as an alternative to where the source code for defined bots configuration are maintained. Automation Anywhere has its own source control and version control features which allow you to compare version histories or bring an older version of a particular bot back in case the new version gets messed up.

This article: [Bot Lifecycle Management: Bring Calm to Your Bot Development Chaos](https://www.automationanywhere.com/company/blog/product-insights/bot-lifecycle-management-bring-calm-to-your-bot-development-chaos) discuss in details the differences between BLM and DevOps for Automation Anywhere

## DevOps steps
In order to move bots from one Automation Anywhere Control Room to another for example dev to uat, you need to use [Control Room APIs](https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/control-room/control-room-api/cloud-control-room-apis.html). This page gives an introduction to control room API and it also include a postman collection which can be used as a playground to understand the API cababilities better

1. Authenticate to source Control Room (using [Authentication API](https://docs.automationanywhere.com/bundle/enterprise-v2019/page/auth-api-supported.html))
2. Create a request to Export Bot(s) with their Id as a zipped package potentially with as a password protected package (using BLM EXPORT API)
3. Prediodically check the status of the export request until it returns `COMPLETED` (using BLM Check Import/Export Status API)
4. Download the generated zip file (using BLM Downloand API)
5. Authenticate to destination Control Room (using Authentication API)
6. Create an Import Bot(s) Request (using BLM Import API)
7. Prediodically check the status of the import request until it returns `COMPLETED` (using BLM Check Import/Export Status API)
8. Once the Status API returns `COMPLETED`, it means that the DevOps operation has been successful

### Authentication
Authentication can be done either with combination of `username` and `apiKey` or `username` and `password`.
For the purpose of this Sample DevOps pipeline we are using API Key.
In order to create an API Key, I asked that my user(used for DevOps) has access to Generate API Keys.
Users in Automation Anywhere are granted access to different features using RBAC which is role-based-access-control. So my user is granted a role which can generate API Keys
Also the API key is only valid by 45 days but this settings can be changed in Automation Anywhere settings.


![Generate API Key Permission](GenerateApiKeyPermission.png)

So I went ahead and created and API Key under my user settings

![Generate API Key in UI](GenerateApiKeyInUI.png)

These simple steps enable you to login and receive the token required for the other steps over the same Control Room.

The request to Authenticate if successful returns token with some additional information about the logged in user and their permissions

![Authenticate to Control Room](Authentication.png)

### Export Request
Export Request is a BML API Request which results in a 202 immediate response if successful.
In order to initiate this request the user must have Export bots, View package, and Check in or Check out permissions to the required folders

![Export Bots API](ExportBots.png)
The `requestId` in the response can be used for further steps to get status and download the results

### Export Status
Import/Export status are the same API and just indicate whether the operation has been successful or pending or failed altogether. What we are looking for is a 200 HttpStatus code with a `Status` of `COMPLETED` in the JSON body of the response

![Import/Export Status](ImportExportStatus.png)

### Download Exported Bots
Using the `requestId` provided in the export request response, the content of the bots can be downloaded as a zip file (password-protected if it was given an `achivePassword` in the export request)

![Download Bots](DownloadBots.png)

### Import Request
As mentioned before now that the bots contents are downloaded, the next steps are authentication to the new control room API and sending a request to import downloaded zip file

There is one major difference between this API and the rest of the API calls. The request body is `form-data` which has its own challenges in DevOps calls

![Import Bots](ImportBots.png)

## Additional Resources

### Useful articles
- [Bot Lifecycle Management: Bring Calm to Your Bot Development Chaos](https://www.automationanywhere.com/company/blog/product-insights/bot-lifecycle-management-bring-calm-to-your-bot-development-chaos)
- [Create API key generation role](https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/control-room/administration/roles/cloud-control-room-apikey-role.html)
- [https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/control-room/control-room-api/cloud-control-room-apis.html](https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/control-room/control-room-api/cloud-control-room-apis.html)
- [https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/bot-insight/user/cloud-bot-lifecycle-management.html](https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/bot-insight/user/cloud-bot-lifecycle-management.html)
- [Bot Lifecycle Management in Automation 360](https://community.automationanywhere.com/developers-blog-85009/bot-lifecycle-management-in-automation-360-85112)
- [Integrating Control Room with Git repositories](https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/control-room/git-integration/cloud-cr-git-integration.html)

### Youtube Videos
- [Build Your First Automation 360 Bot with Micah Smith](https://www.youtube.com/watch?v=nMUIZx6eAJA&t=465s)
- [Using Version Control in Automation 360 v.22](https://www.youtube.com/watch?v=_646qiId3no)
- [Introduction to the Control Room API](https://www.youtube.com/watch?v=zv34BRfW96Y&t=10s)
- [How to Export a Bot Using the Automation 360 Control Room API](https://www.youtube.com/watch?v=xcAHUvGCgE0)