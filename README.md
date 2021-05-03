# Wharf

Simple, automatic Docker image build and push.

For each image, add a file to your config directory.
An example is provided.
The format is as follows:

```
local repository absolue path
repository branch to build against
relative path of dockerfile
docker image name (without color or tag)
short hash of most recent successful build (add this as a blank line to start)
```

Run with cron.
In this example, run every 15 minutes:
```
*/15 * * * * /home/jacobmarble/projects/wharf/wharf.sh /home/jacobmarble/projects/wharf/config/
```

