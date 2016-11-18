# BackGroundDownload
Test the different way to make background download task for iOS.

#Test way

Create a http-server use [this](https://www.npmjs.com/package/http-server), download file one by one.

* First way: Create all the task in front and then inactive the app
* Second Way : Create one task, resume it, after download finish, creat the next task

Actually, you will find that the second way will be very very slow.
