import { AnalyticsFilter, TopComponent } from "shared/types";
import { transformAnalyticsFilter } from "../utils/formatDate";

const apiHost = import.meta.env.VITE_API_HOST as string;

export const getTopComponents = async (
  filters: AnalyticsFilter,
  datasetId: string,
): Promise<TopComponent[]> => {
  // This is a mock implementation until the backend endpoint is created
  // Eventually this will fetch real data from:
  // ${apiHost}/analytics/components
  
  // For now, we're returning mock data that represents the top components by interaction count
  // This will be replaced with actual API call once the backend is implemented
  const mockData: TopComponent[] = [
    {
      component_name: "SearchInput",
      interaction_count: 1245,
    },
    {
      component_name: "ResultList",
      interaction_count: 982,
    },
    {
      component_name: "FilterDropdown",
      interaction_count: 734,
    },
    {
      component_name: "ChatWidget",
      interaction_count: 521,
    },
    {
      component_name: "PaginationControls",
      interaction_count: 403,
    },
  ];

  return mockData;
};