import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "extend-category-depth",
  initialize() {
    withPluginApi("0.8.31", api => {
      api.modifyClass("controller:edit-category", {
        parentCategories: function() {
          return this.site.categories.filter(c => {
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