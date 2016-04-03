# JSS Switcher
I'm one of many Mac admins that has several JSS instances, in my case live and test, and need to flick between the two regularly.

I know that I can hold down the alt key when launching one of the admin tools to pull up the JSS selector screen and type the address every time to ensure I'm on the correct one but that's cumbersome, prone to typo's and a bit of pain to be honest.

I raised a feature request with Jamf around this, but had enough waiting so wrote a little script to allow easy switching and launching of the app I want to use.

I use Pashua for a simple dialog box and have a preconfigured drop down list to select the JSS.

It has a quick ping test to check the JSS is reachable before launching the selected application.

It works well if made into an application with Automator.

