# report is just a special type of resource.
class Report

  include Triploid::Resource

  # # override attributes to allow new getters.
  # def self.attributes
  #   super.merge(
  #     {
  #        #blah.
  #     })
  # end

  # def self.all
  #   # get all reports
  # end

  # # idea:

  # # to create: make new, then add_to_data() to create predicate-object pairs.
  # # then call save .

  # # to udpate: do a find, then update the contents of @data.

  # # save will check new_record?(), then do an update or insert accordingly,
  # # based on contents of @data.


  # # new method ?
  # # TODO: add to resource via a module, so useable by zones too.
  # def update_data

  # end

  # # TODO: allow setting of attributes via method-missing style too?





end