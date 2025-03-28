# Create teams from the contents of "teams.csv"
resource "github_team" "all" {
  for_each = {
    for team in csvdecode(file("teams.csv")) :
    team.name => team
  }

  name        = each.value.name
  description = each.value.description
  privacy     = each.value.privacy
}

# Populate team members based on the csv files in the team-members directory.
resource "github_team_membership" "members" {
  for_each = { for tm in local.team_members : tm.name => tm }

  team_id  = each.value.team_id
  username = each.value.username
  role     = each.value.role
}

## This creates an "all-members" team containing all organization members.
#resource "github_team" "all-members" {
#  name        = "all-members"
#  description = "All organization members"
#  privacy     = "closed"
#}
#
#resource "github_team_membership" "all-members" {
#  for_each = {
#    for member in csvdecode(file("members.csv")) :
#    member.username => member
#  }
#
#  team_id  = "all-members"
#  role     = each.value.role == "admin" ? "maintainer" : "member"
#  username = each.value.username
#
#  depends_on = [github_team.all-members]
#}

# This populates nerc-org-admins with organization owners
resource "github_team" "nerc-org-admins" {
  name        = "nerc-org-admins"
  description = "Organization admins"
  privacy     = "closed"
}

resource "github_team_membership" "nerc-org-admins" {
  for_each = {
    for member in csvdecode(file("members.csv")) :
    member.username => member if member.role == "admin"
  }

  team_id  = "nerc-org-admins"
  role     = each.value.role == "admin" ? "maintainer" : "member"
  username = each.value.username

  depends_on = [github_team.nerc-org-admins]
}
