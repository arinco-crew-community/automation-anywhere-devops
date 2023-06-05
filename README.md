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
In order to move bots from one Automation Anywhere Control Room to another for example dev to uat, you need to use [Control Room APIs](https://docs.automationanywhere.com/bundle/enterprise-v2019/page/enterprise-cloud/topics/control-room/control-room-api/cloud-control-room-apis.html)


## Additional Resources

### Youtube Videos
- [Build Your First Automation 360 Bot with Micah Smith](https://www.youtube.com/watch?v=nMUIZx6eAJA&t=465s)
- [Using Version Control in Automation 360 v.22](https://www.youtube.com/watch?v=_646qiId3no)
- [Introduction to the Control Room API](https://www.youtube.com/watch?v=zv34BRfW96Y&t=10s)
- [How to Export a Bot Using the Automation 360 Control Room API](https://www.youtube.com/watch?v=xcAHUvGCgE0)