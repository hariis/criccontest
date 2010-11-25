module NotifiersHelper
  def get_teamname(teamid)
    Team.find_by_id(teamid).teamname
  end
end