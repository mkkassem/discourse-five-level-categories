// assets/javascripts/discourse/initializers/extend-category-modal.js.es6
import { withPluginApi } from "discourse/lib/plugin-api";
import Category from "discourse/models/category";

export default {
  name: "extend-category-modal",
  initialize() {
    withPluginApi("0.8.31", api => {
      api.modifyClass("controller:edit-category", {
        parentCategories: function() {
          return Category.list().filter(c => {
            // Only show categories that haven't reached max depth
            return c.depth < Category.max_depth - 1;
          });
        }.property("site.categories"),

        actions: {
          changeParentCategory(parent) {
            if (parent && parent.depth >= Category.max_depth - 1) {
              bootbox.alert(I18n.t("category.max_depth_reached"));
              return;
            }
            this._super(parent);
          }
        }
      });
    });
  }
};

